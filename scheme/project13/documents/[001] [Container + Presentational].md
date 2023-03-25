## [Angular Architecture - Smart Components vs Presentational Components](https://blog.angular-university.io/angular-2-smart-components-vs-presentation-components-whats-the-difference-when-to-use-each-and-why/)

In Angular, the concept of **Smart Components** and **Presentational Components** is derived from a broader architectural pattern often referred to as **Container-Presenter** or **Smart-Dumb** components. This pattern helps in creating a clear separation of concerns within your application by dividing responsibilities between components that manage state and logic (smart) and those that focus on rendering UI (presentational).

### 1. **Smart Components (Container Components)**

**Smart components**, also known as **container components**, are responsible for managing the business logic, interacting with services, handling data fetching, and passing data down to presentational components. They typically:

- **Manage State**: Smart components hold the state and manage how it changes.
- **Handle Side Effects**: They handle side effects like API calls, subscriptions, routing, etc.
- **Pass Data Down**: They pass data and callbacks (functions) to presentational components via `@Input` and `@Output`.
- **Interact with Services**: They interact with Angular services to fetch or update data.

#### Characteristics:
- **Aware of Application Logic**: They are aware of the overall application state and logic.
- **Less Reusable**: Because they are tied to specific business logic, they tend to be less reusable across different parts of the application.
- **Located Higher in the Component Tree**: Typically located higher in the component tree where they can manage state and orchestrate child components.

#### Example:
```typescript
import { Component, OnInit } from '@angular/core';
import { DataService } from './data.service';

@Component({
  selector: 'app-smart',
  template: `
    <app-presentational 
      [items]="items" 
      (itemSelected)="onItemSelected($event)">
    </app-presentational>
  `
})
export class SmartComponent implements OnInit {
  items: any[] = [];

  constructor(private dataService: DataService) {}

  ngOnInit() {
    this.dataService.getItems().subscribe(data => {
      this.items = data;
    });
  }

  onItemSelected(item: any) {
    console.log('Item selected:', item);
    // Handle item selection logic here
  }
}
```

### 2. **Presentational Components (Dumb Components)**

**Presentational components**, also known as **dumb components**, are focused solely on rendering the UI based on inputs they receive. They don't manage state or interact with services directly. Instead, they receive data via `@Input` properties and emit events via `@Output` properties to communicate with their parent (smart) components.

#### Characteristics:
- **Focused on UI**: They are concerned only with how things look (UI).
- **Highly Reusable**: Since they don’t contain business logic, they can be reused across different parts of the application.
- **Stateless**: They do not manage their own state; instead, they rely on inputs from smart components.
- **Emit Events**: They emit events using `@Output` to notify parent components about user interactions.

#### Example:
```typescript
import { Component, Input, Output, EventEmitter } from '@angular/core';

@Component({
  selector: 'app-presentational',
  template: `
    <ul>
      <li *ngFor="let item of items" (click)="selectItem(item)">
        {{ item.name }}
      </li>
    </ul>
  `
})
export class PresentationalComponent {
  @Input() items: any[] = [];
  @Output() itemSelected = new EventEmitter<any>();

  selectItem(item: any) {
    this.itemSelected.emit(item);
  }
}
```

### Key Differences Between Smart and Presentational Components:

| Aspect                     | Smart Components (Containers)           | Presentational Components (Dumb)       |
|----------------------------|-----------------------------------------|----------------------------------------|
| **Responsibility**          | Manage state, logic, and side effects   | Render UI based on inputs              |
| **Awareness of State**      | Yes                                     | No                                     |
| **Interaction with Services**| Yes                                     | No                                     |
| **Reusability**             | Low                                     | High                                   |
| **Data Flow**               | Fetch data and pass it down             | Receive data via `@Input`, emit events via `@Output` |
| **Location in Component Tree** | Higher in the hierarchy                 | Lower in the hierarchy                 |

### Benefits of Using Smart and Presentational Components:

1. **Separation of Concerns**: By separating logic and presentation, you make your codebase easier to maintain and test.

2. **Reusability**: Presentational components can be reused across different parts of the application without worrying about business logic.

3. **Testability**: Smart components can be tested independently for their logic, while presentational components can be tested for their UI behavior.

4. **Scalability**: As your application grows, having a clear separation between logic and presentation makes it easier to scale and refactor.

### When to Use Smart vs. Presentational Components:

- **Use Smart Components** when:
    - You need to manage complex state or business logic.
    - You need to interact with services (e.g., fetching data from an API).
    - You need to handle routing or other side effects.

- **Use Presentational Components** when:
    - You want to create reusable UI elements (like buttons, lists, forms).
    - The component’s sole responsibility is to render UI based on input data.
    - You want to keep the component simple and focused on the view layer.

### Conclusion

The **Smart-Presentational** component architecture is a powerful way to structure your Angular applications. It promotes clean separation of concerns, making your code more modular, maintainable, and testable. By clearly defining which components are responsible for logic and which are responsible for UI, you can build scalable and efficient Angular applications.