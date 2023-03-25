/******************************************
 * Constants
 ******************************************/
var scalrClass = makeClass('org.imgscalr.Scalr');
var scalrMethodClass = makeClass('org.imgscalr.Scalr.Method');
var scalrRotationClass = makeClass('org.imgscalr.Scalr.Rotation');
var binaryBitmapClass = makeClass('com.google.zxing.BinaryBitmap');
var hybridBinarizerClass = makeClass('com.google.zxing.common.HybridBinarizer');
var bufferedImageLuminanceSourceClass = makeClass('com.google.zxing.client.j2se.BufferedImageLuminanceSource');
var pdf417ReaderClass = makeClass('com.google.zxing.pdf417.PDF417Reader');
var zxingNotFoundExceptionClass = makeClass('com.google.zxing.NotFoundException');
var commandResultCls = makeAppCommandResultClass();

var SCALE_MAX_FACTOR = 3;
var ROTATION_LIST = [null, scalrRotationClass.CW_90];

/*****************************
 * Decode single barcode
 *****************************/
function decodeBarcode(fileAsBase64, scaleFactor, rotation) {
  var initialImage,
    barCodeScaledImage,
    barcodeRotatedImage;

  try {
    initialImage = readBufferedImage(atob(fileAsBase64));
    barCodeScaledImage = scaleFactor === 0
      ? initialImage
      : scalrClass.resize(
        initialImage, scalrMethodClass.BALANCED,
        initialImage.getWidth() * scaleFactor,
        initialImage.getHeight() * scaleFactor
      );

    barcodeRotatedImage = isNull(rotation)
      ? barCodeScaledImage
      : scalrClass.rotate(barCodeScaledImage, rotation);

    return new pdf417ReaderClass()
      .decode(toBinaryBitmap(barcodeRotatedImage))
      .getText();
  } catch (e) {
    var base64Hash = hash(fileAsBase64);
    if (e instanceof zxingNotFoundExceptionClass) {
      console.trace('[$barcode.decode] A barcode is not found {}. Exception: {}', base64Hash, e);
    } else {
      console.error('[$barcode.decode] An exception occurred while scanning the barcode {}. Exception: {}', base64Hash, e);
    }
  }
  return null;
}

/*****************************
 * Barcode decoder
 *****************************/
function decode(fileAsBase64, callback) {
  var scaleFactor,
    from = Date.now(),
    tasks = [],
    atomicReference = getAtomicReference();

  for (scaleFactor = 0; scaleFactor <= SCALE_MAX_FACTOR; scaleFactor++) {
    ROTATION_LIST.forEach(function (rotation) {
      var newTask;
      if (atomicReference.get() !== null) {
        return;
      }

      newTask = spawnTask(
        function (args) {
          var decodedValue = decodeBarcode(fileAsBase64, args[0], args[1]);
          if (decodedValue
                // Update to NOT NULL decoded value ONLY IF previous value IS NULL and current value IS NOT NULL
                && atomicReference.compareAndSet(null, decodedValue)
          ) {
            tasks.forEach(function (listenableFuture) {
              listenableFuture.cancel(true);
            });
            console.log('[$barcode.decode] Barcode has been found. Time: {}', (Date.now() - from) * 0.001);
            callback(decodedValue);
          } else {
            tasks = tasks.filter(function (cTask) {
              return cTask !== newTask;
            });

            if (!tasks.length) {
              console.log('[$barcode.decode] Barcode has NOT been found. Time: {}', (Date.now() - from) * 0.001);
              callback(null);
            }
          }
        },
        [scaleFactor, rotation]
      );
      tasks.push(newTask);
    });
  }
}

function toBinaryBitmap(bufferedImage) {
  return new binaryBitmapClass(new hybridBinarizerClass(new bufferedImageLuminanceSourceClass(bufferedImage)));
}

/*****************************
 * Task hooks
 *****************************/
defineTaskMessageHook(function (taskMessage) {
  var command = taskMessage.getMessage(),
    base64 = command.getParamByName('base64').getParamValue(),
    result = new commandResultCls,
    commandProducer = command.getProducer();

  decode(base64, function (decodedData) {
    sendMessage(
      result.fromObject(command).setData(decodedData),
      isDef(commandProducer) ? commandProducer : taskMessage.getSourceTask().getTaskName()
    );
  });
});

defineTaskStopHook(function () {
  // Nothing to do
});

/*****************************
 * Sleep
 *****************************/
sleep();