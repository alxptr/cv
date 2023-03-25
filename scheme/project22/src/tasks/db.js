/******************************************
 * Constants
 ******************************************/
var dbClass = makeClass('org.h2.tools.Server');
var javaLangClass = makeClass('java.lang.Class');
var connectionManager = makeClass('java.sql.DriverManager');
var appObjectStatusClass = makeAppObjectStatusClass();

/******************************************
 * DB Server Constants
 ******************************************/
var DB_DIRECTORY = getWorkingTaskDirectory();
var DATABASE_NAME = 'pos';
var DB_DRIVER = 'org.h2.Driver';
var DB_CONNECTION = 'jdbc:h2:' + DB_DIRECTORY + '/' + DATABASE_NAME;
var DB_USER = '';
var DB_PASSWORD = '';
var DB_READY_STATUS = 1;

console.debug('[$db] DB connection string: {}', DB_CONNECTION);

/******************************************
 * DB API
 ******************************************/
var executeRequest = function (statementFn) {
  var conn = null;
  try {
    conn = connectionManager.getConnection(DB_CONNECTION, DB_USER, DB_PASSWORD);
    conn.setAutoCommit(false);
    statementFn(conn);
    conn.commit();
  } catch (e) {
    console.error('[$db] An exception occurred while request the statement. Exception: {}', e);
    if (conn !== null) {
      conn.rollback();
    }
  } finally {
    if (conn !== null) {
      conn.close();
    }
  }
};

var executeStatement = function (sqls) {
  executeRequest(function (conn) {
    invokeStatement(conn, sqls);
  });
};

var invokeStatement = function (conn, sqls) {
  (isString(sqls) ? [sqls] : sqls).forEach(function (sql) {
    var statement = null;
    try {
      (statement = conn.createStatement()).execute(sql);
      console.debug('[$db] Sql statement {} has been invoked.', sql);
    } finally {
      if (statement !== null) {
        statement.close();
      }
    }
  })
};

var executePreparedStatement = function (stmts) {
  executeRequest(function (conn) {
    invokePreparedStatement(conn, stmts);
  });
};

var invokePreparedStatement = function (conn, stmts) {
  (Array.isArray(stmts) ? stmts : [stmts]).forEach(function (stmt) {
    var statement = null,
      result = null;
    try {
      statement = conn.prepareStatement(stmt.sql);
      (stmt.parameters || []).forEach(function (parameter, index) {
        statement.setObject(index + 1, parameter);
      });
      result = statement.executeUpdate();
      if (stmt.handler) {
        stmt.handler(result, conn);
      }
      console.debug('[$db] Prepared statement {} has been invoked. Result: {}', JSON.stringify(stmt), result);
    } finally {
      if (statement !== null) {
        statement.close();
      }
    }
  })
};

var executeQuery = function (sql, handler) {
  executeRequest(function (conn) {
    invokeQuery(conn, sql, handler);
  });
};

var invokeQuery = function (conn, sql, handler) {
  var statement = null,
    resultSet = null;

  try {
    handler(resultSet = (statement = conn.createStatement()).executeQuery(sql));
    console.debug('[$db] Sql query {} has been invoked.', sql);
  } finally {
    if (resultSet !== null) {
      resultSet.close();
    }
    if (statement !== null) {
      statement.close();
    }
  }
};

var executeMeta = function (metaObject, metaTypes, handler) {
  executeRequest(function (conn) {
    var resultSet = null;
    try {
      handler(
        resultSet = conn.getMetaData().getTables(null, null, metaObject, [].concat(metaTypes))
      );
    } finally {
      if (resultSet !== null) {
        resultSet.close();
      }
    }
  });
};

/******************************************
 * DB server
 ******************************************/
var strClass = makeClass('java.lang.String');
var server = dbClass.createTcpServer().start();

(function () {
  try {
    javaLangClass.forName(DB_DRIVER);
    console.debug('[$db] The DB driver has been loaded successfully!');
  } catch (e) {
    console.error('[$db] Can\'t load the DB driver. Exception: {}', e.getMessage());
  }
})();

/*****************************
 * Start the server
 *****************************/
server.start();

/*****************************
 * Task hooks
 *****************************/
defineTaskMessageHook(function (taskMessage) {
  var message = taskMessage.getMessage();

  if (message && isObject(message)) {
    switch (message.cmd) {
      case 'prepared.statement':
        executePreparedStatement(message.statement);
        break;
      case 'statement':
        executeStatement(message.sql);
        break;
      case 'query':
        executeQuery(message.sql, message.handler);
        break;
      case 'meta':
        executeMeta(message.object, message.types, message.handler);
        break;
    }
  }
});

defineTaskStopHook(function () {
  server.stop();
});

/*****************************
 * DB ready message
 *****************************/
sendMessage(
  new appObjectStatusClass().setStatus(DB_READY_STATUS).setObject(getTaskName())
);

/*****************************
 * Sleep
 *****************************/
sleep();