## [React Architecture - Smart Components vs Presentational Components: An Overview](https://medium.com/@dan_abramov/smart-and-dumb-components-7ca2f9a7c7d0).

In React, one of the most widely adopted architectural patterns is the distinction between **Smart Components** (also known as **Container Components**) and **Presentational Components**. This separation helps developers create maintainable, reusable, and scalable code by clearly dividing responsibilities between components. Below is a detailed explanation of this pattern:

---

### **1. Smart Components (Container Components)**

#### **Definition**
Smart components are responsible for managing data, state, and business logic. They are often connected to external sources like APIs, global state management libraries (e.g., Redux, Context API), or other data-fetching mechanisms. These components focus on "how things work" rather than "how things look."

#### **Characteristics**
- **Stateful**: They manage their own state or interact with global state.
- **Data Fetching**: Responsible for fetching data from APIs or other sources.
- **Logic Handling**: Contain business logic, such as calculations, validations, or event handlers.
- **Pass Data to Presentational Components**: They pass data and callbacks (e.g., event handlers) as props to presentational components.
- **Rarely Include UI Logic**: Typically do not contain JSX for rendering UI elements directly.

#### **Example**
```jsx
import React, { useState, useEffect } from 'react';
import UserList from './UserList'; // Presentational Component

const UserContainer = () => {
  const [users, setUsers] = useState([]);

  useEffect(() => {
    // Simulating data fetching
    fetch('https://api.example.com/users')
      .then((response) => response.json())
      .then((data) => setUsers(data));
  }, []);

  const handleDelete = (userId) => {
    setUsers(users.filter((user) => user.id !== userId));
  };

  return <UserList users={users} onDelete={handleDelete} />;
};

export default UserContainer;
```

---

### **2. Presentational Components**

#### **Definition**
Presentational components focus solely on rendering the UI. They are "dumb" in the sense that they do not manage state or business logic. Instead, they receive all necessary data and behavior via props. These components are concerned with "how things look."

#### **Characteristics**
- **Stateless**: Do not manage their own state (unless it's purely for UI purposes, like animations).
- **Props-Driven**: Rely entirely on props for data and behavior.
- **Reusable**: Designed to be reusable across different parts of the application.
- **Declarative**: Focus on declaratively describing the UI based on the props provided.
- **No Side Effects**: Do not perform side effects like data fetching or subscriptions.

#### **Example**
```jsx
import React from 'react';

const UserList = ({ users, onDelete }) => {
  return (
    <ul>
      {users.map((user) => (
        <li key={user.id}>
          {user.name}
          <button onClick={() => onDelete(user.id)}>Delete</button>
        </li>
      ))}
    </ul>
  );
};

export default UserList;
```

---

### **Key Differences Between Smart and Presentational Components**

| Aspect                  | Smart Components (Containers)               | Presentational Components         |
|-------------------------|---------------------------------------------|------------------------------------|
| **Purpose**             | Manage state, logic, and data              | Render UI                         |
| **State Management**    | Stateful                                   | Stateless (props-driven)          |
| **Data Fetching**       | Fetch data from APIs or global state       | Receive data via props            |
| **Reusability**         | Less reusable (specific to app logic)      | Highly reusable                   |
| **UI Concerns**         | Rarely include UI logic                    | Focused on UI                     |
| **Dependencies**        | May depend on external libraries (e.g., Redux) | Independent of external libraries |

---

### **Advantages of This Separation**

1. **Separation of Concerns**:
    - By separating logic (smart components) from presentation (presentational components), the codebase becomes easier to understand and maintain.

2. **Reusability**:
    - Presentational components can be reused across different parts of the application without duplicating logic.

3. **Testability**:
    - Smart components can be tested for their logic and state management, while presentational components can be tested for their rendering behavior.

4. **Scalability**:
    - As the application grows, this pattern ensures that components remain modular and focused on specific responsibilities.

5. **Collaboration**:
    - Designers and developers can collaborate more effectively since presentational components align closely with design systems.

---

### **Modern Context: Hooks and Functional Components**
With the introduction of **React Hooks**, the distinction between smart and presentational components has become less rigid. Functional components can now manage state and side effects using hooks like `useState` and `useEffect`. However, the underlying principle of separating concerns remains relevant.

For example:
- A functional component with `useState` and `useEffect` can act as a smart component.
- Another functional component that only receives props and renders JSX can act as a presentational component.

---

### **When to Use This Pattern**
While this pattern is highly beneficial, it is not mandatory for every React application. Here are some guidelines:
- **Use It When**: The application is large, complex, or requires clear separation of concerns.
- **Avoid Overusing It**: For small applications or simple UIs, forcing this separation might add unnecessary complexity.

---

### **Conclusion**
The **Smart vs Presentational Component** pattern is a powerful architectural approach in React that promotes clean, maintainable, and scalable code. By clearly defining the roles of components, developers can build applications that are easier to test, extend, and collaborate on. However, with modern React features like hooks, the boundaries between these two types of components have blurred, but the core principles of separation of concerns remain invaluable.