## [Angular Architecture - Smart Components vs Presentational Components: An Overview](https://blog.angular-university.io/angular-2-smart-components-vs-presentation-components-whats-the-difference-when-to-use-each-and-why).

In Angular, the architecture of an application can significantly impact its maintainability, scalability, and readability. One widely adopted pattern in Angular is the separation of **Smart Components** (also known as Container Components) and **Presentational Components** (also known as Dumb Components). This pattern helps organize code by separating concerns and promoting reusability.

Here’s a detailed explanation of both types of components:

---

### **1. Smart Components (Container Components)**

#### **Definition**
Smart components are responsible for managing the business logic, state, and interactions with services or external systems. They act as intermediaries between the application's data layer and the presentational components.

#### **Characteristics**
- **Stateful**: They manage the state of the application or a part of it.
- **Data Fetching**: They fetch data from services, APIs, or other sources.
- **Event Handling**: They handle user actions and delegate them to appropriate services or child components.
- **Communication**: They pass data and callbacks to presentational components via `@Input` and `@Output`.
- **Routing**: They often interact with Angular's router to navigate between views.
- **Less Reusable**: Since they are tied to specific business logic, they are less reusable across different contexts.

#### **Example**
```typescript
@Component({
  selector: 'app-user-list',
  template: `<app-user-item 
                *ngFor="let user of users" 
                [user]="user" 
                (delete)="onDeleteUser($event)">
             </app-user-item>`
})
export class UserListComponent implements OnInit {
  users: User[] = [];

  constructor(private userService: UserService) {}

  ngOnInit(): void {
    this.userService.getUsers().subscribe((data) => {
      this.users = data;
    });
  }

  onDeleteUser(userId: number): void {
    this.userService.deleteUser(userId).subscribe(() => {
      this.users = this.users.filter(user => user.id !== userId);
    });
  }
}
```

---

### **2. Presentational Components (Dumb Components)**

#### **Definition**
Presentational components focus solely on rendering the UI. They receive data and callbacks from their parent (smart component) and do not manage any state or interact with services directly.

#### **Characteristics**
- **Stateless**: They rely entirely on inputs (`@Input`) and outputs (`@Output`) for data and events.
- **Reusability**: They are highly reusable because they are decoupled from business logic.
- **No Side Effects**: They do not fetch data, interact with services, or manage state.
- **UI-Centric**: Their primary purpose is to display data and capture user interactions.
- **Testable**: Since they are simple and focused on rendering, they are easier to test.

#### **Example**
```typescript
@Component({
  selector: 'app-user-item',
  template: `
    <div>
      <span>{{ user.name }}</span>
      <button (click)="onDelete.emit(user.id)">Delete</button>
    </div>
  `
})
export class UserItemComponent {
  @Input() user!: User;
  @Output() delete = new EventEmitter<number>();

  onDelete(): void {
    this.delete.emit(this.user.id);
  }
}
```

---

### **Key Differences Between Smart and Presentational Components**

| Feature                  | Smart Components (Container)          | Presentational Components (Dumb)       |
|--------------------------|---------------------------------------|-----------------------------------------|
| **Purpose**              | Manage state and business logic       | Render UI and handle user interactions |
| **State Management**     | Stateful                              | Stateless                               |
| **Data Fetching**        | Fetch data from services/APIs         | Receive data via `@Input`               |
| **Reusability**          | Less reusable                         | Highly reusable                        |
| **Interaction**          | Interact with services and routing    | Emit events via `@Output`               |
| **Complexity**           | More complex                          | Simpler and focused                    |

---

### **Benefits of Separating Smart and Presentational Components**

1. **Separation of Concerns**: By dividing responsibilities, each component has a single responsibility, making the codebase easier to understand and maintain.
2. **Reusability**: Presentational components can be reused across different parts of the application without duplicating logic.
3. **Testability**: Presentational components are easier to test because they are isolated from business logic and services.
4. **Scalability**: As the application grows, the separation ensures that changes in business logic do not affect the UI layer and vice versa.
5. **Collaboration**: Designers and developers can work independently on presentational components without worrying about the underlying logic.

---

### **When to Use Each Type**

- **Use Smart Components**:
    - When you need to manage application state or interact with services.
    - For pages or sections of the application that require complex logic.
    - When integrating with Angular's router or handling route parameters.

- **Use Presentational Components**:
    - For reusable UI elements like buttons, cards, lists, or forms.
    - When the component only needs to display data or capture user input.
    - To keep the UI layer decoupled from business logic.

---

### **Best Practices**

1. **Keep Presentational Components Stateless**: Avoid introducing state or logic into presentational components.
2. **Minimize Smart Components**: Only create smart components when necessary to avoid over-complicating the application.
3. **Use Shared Modules**: Place reusable presentational components in shared modules to promote reusability.
4. **Leverage Angular Features**: Use Angular's dependency injection, `@Input`, and `@Output` decorators effectively to facilitate communication between components.
5. **Follow Naming Conventions**: Use consistent naming conventions to distinguish between smart and presentational components (e.g., `UserListContainer` vs `UserItemComponent`).

---

By adhering to the principles of smart and presentational components, you can build Angular applications that are modular, maintainable, and scalable. This separation of concerns is a cornerstone of clean architecture in modern front-end development.