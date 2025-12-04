# Design Patterns Documentation

A comprehensive guide to 22 classic design patterns based on refactoring.guru's catalog.

---

## Table of Contents

### Creational Patterns
1. [Factory Method](#factory-method)
2. [Abstract Factory](#abstract-factory)
3. [Builder](#builder)
4. [Prototype](#prototype)
5. [Singleton](#singleton)

### Structural Patterns
6. [Adapter](#adapter)
7. [Bridge](#bridge)
8. [Composite](#composite)
9. [Decorator](#decorator)
10. [Facade](#facade)
11. [Flyweight](#flyweight)
12. [Proxy](#proxy)

### Behavioral Patterns
13. [Chain of Responsibility](#chain-of-responsibility)
14. [Command](#command)
15. [Iterator](#iterator)
16. [Mediator](#mediator)
17. [Memento](#memento)
18. [Observer](#observer)
19. [State](#state)
20. [Strategy](#strategy)
21. [Template Method](#template-method)
22. [Visitor](#visitor)

---

## Creational Patterns

Creational patterns provide various object creation mechanisms, which increase flexibility and reuse of existing code.

### Factory Method

**Intent:** Provides an interface for creating objects in a superclass, but allows subclasses to alter the type of objects that will be created.

**Problem:** Code becomes tightly coupled to concrete product classes when creating objects directly. Adding new product types requires extensive modifications throughout the codebase.

**When to Use:**
- You don't know in advance which specific types your code must work with
- You want library users to extend internal components through inheritance
- You need to reuse expensive objects from a pool rather than creating new instances each time

**Key Components:**
- **Product Interface** - Declares common operations all concrete products must implement
- **Concrete Products** - Different implementations of the product interface
- **Creator** - Declares the factory method returning product objects
- **Concrete Creators** - Override the factory method to return different product types

---

### Abstract Factory

**Intent:** Enables production of families of related objects without specifying their concrete classes.

**Problem:** Applications often need to create compatible object families (e.g., furniture in Modern, Victorian, or ArtDeco styles). Direct instantiation creates tight coupling and makes adding new product variants difficult.

**When to Use:**
- Your code works with multiple families of related products
- You want to avoid dependency on concrete product classes
- You need flexibility to introduce new product variants without modifying existing code

**Key Components:**
- **Abstract Products** - Interfaces for each product type in the family
- **Concrete Products** - Specific implementations grouped by variant
- **Abstract Factory** - Interface declaring creation methods for all abstract products
- **Concrete Factories** - Implementations creating only their specific product variants
- **Client** - Works exclusively through abstract interfaces

**Example:** A cross-platform UI framework creates buttons and checkboxes matching the operating system without client code knowing concrete implementation details.

---

### Builder

**Intent:** Constructs complex objects step by step, enabling different representations using the same construction code.

**Problem:** Avoids telescoping constructors with numerous optional parameters and eliminates the need for countless subclasses to handle every configuration variation.

**When to Use:**
- Objects require extensive, step-by-step initialization
- You need to create multiple representations of similar products
- You're building complex composite structures or trees
- Product construction involves similar steps that vary only in implementation details

**Key Components:**
- **Builder Interface** - Declares all possible construction steps
- **Concrete Builders** - Implement specific construction step variants
- **Products** - The resulting objects (needn't share a common interface)
- **Director** - Encapsulates the sequence of construction steps (optional)
- **Client** - Associates a builder with a director and initiates construction

**Benefit:** Separates construction logic from business logic through incremental assembly.

---

### Prototype

**Intent:** Creates new objects by copying existing objects without making code dependent on their classes.

**Problem:** Direct object copying is problematic because private fields aren't accessible externally, and code becomes tightly coupled to concrete classes.

**When to Use:**
- Code shouldn't depend on concrete classes of objects needing copying
- Working with third-party objects via interfaces with unknown implementations
- To reduce subclass proliferation by using pre-configured prototypes instead

**Key Components:**
- **Prototype Interface** - Declares the `clone()` method
- **Concrete Prototype** - Implements cloning, copying all field values
- **Client** - Produces copies via the prototype interface
- **Prototype Registry** - Stores frequently-used prototypes (optional)

**How It Works:** Objects supporting cloning implement a common interface. The clone method creates a new instance and transfers field values, including private ones.

---

### Singleton

**Intent:** Ensures a class has only one instance while providing a global access point to this instance.

**Problem:** Prevents multiple instances of expensive resources (like database connections) from being created accidentally while providing controlled global access.

**When to Use:**
- Your program needs exactly one instance of a class accessible throughout the application
- You need stricter control over global variables than standard approaches provide

**Key Components:**
- **Private Constructor** - Prevents direct instantiation via the `new` operator
- **Static Instance Field** - Stores the single class instance
- **Static getInstance() Method** - Controls instance creation and retrieval with lazy initialization
- **Business Logic Methods** - Perform the actual work on the singleton instance

---

## Structural Patterns

Structural patterns explain how to assemble objects and classes into larger structures while keeping these structures flexible and efficient.

### Adapter

**Intent:** Enables objects with incompatible interfaces to collaborate by converting one object's interface into another.

**Problem:** When integrating incompatible systems (legacy code, third-party libraries, external services), direct communication fails due to interface mismatches.

**When to Use:**
- You need to use an existing class with an incompatible interface
- You want to reuse subclasses lacking common functionality
- You need to make legacy or third-party code work with your application

**Key Components:**
- **Client Interface** - Protocol the client expects
- **Service** - Incompatible class (often third-party)
- **Adapter** - Translates between interfaces
- **Client** - Contains business logic using the adapter

**Approaches:**
- **Object Adapter** (composition-based) - Wraps the incompatible service object
- **Class Adapter** (inheritance-based) - Inherits from both interfaces (requires multiple inheritance)

---

### Bridge

**Intent:** Decouples a large class or related classes into two independent hierarchies—abstraction and implementation—allowing each to evolve separately.

**Problem:** Extending classes across multiple dimensions creates exponential growth in inheritance hierarchies. For example, supporting shapes and colors requires combinations that multiply with each new dimension.

**When to Use:**
- Dividing monolithic classes with multiple functionality variants
- Extending classes across independent dimensions
- Needing runtime implementation switching

**Key Components:**
- **Abstraction** - High-level control layer that delegates work
- **Implementation** - Interface defining common operations for all implementations
- **Concrete Implementations** - Platform-specific code
- **Refined Abstractions** - Variants of control logic extending the base abstraction
- **Client** - Links abstraction objects with appropriate implementation objects

**Solution:** Use object composition instead of inheritance to prevent combinatorial explosion.

---

### Composite

**Intent:** Composes objects into tree structures and works with these structures as if they were individual objects.

**Problem:** Treating simple and complex elements uniformly in hierarchical data becomes difficult when direct approaches require knowing concrete classes and nesting levels beforehand.

**When to Use:**
- You have a tree-like object structure to implement
- You want client code to treat both simple and complex elements uniformly

**Key Components:**
- **Component Interface** - Declares operations common to simple and complex elements
- **Leaf** - Represents basic tree elements without sub-elements
- **Container (Composite)** - Contains sub-elements and delegates work recursively
- **Client** - Works with all elements through the component interface

**Benefit:** Enables recursive behavior across entire object trees without coupling to specific concrete classes.

---

### Decorator

**Intent:** Adds new functionality to objects dynamically by wrapping them in specialized wrapper objects.

**Problem:** Extending object behavior at runtime without creating an explosion of subclasses. Solves the "combinatorial explosion" challenge when supporting multiple feature combinations.

**When to Use:**
- You need to assign extra behaviors to objects at runtime without breaking existing code
- It's awkward or impossible to use inheritance (e.g., with final classes)
- You want to compose multiple behaviors dynamically

**Key Components:**
- **Component Interface** - Defines common operations for wrappers and wrapped objects
- **Concrete Component** - The base object being wrapped
- **Base Decorator** - Holds a reference to a wrapped object and delegates operations
- **Concrete Decorators** - Add specific behaviors before or after delegating
- **Client** - Composes multiple decorator layers as needed

**Example:** Supporting multiple notification types (email, SMS, Facebook, Slack) without creating dozens of class combinations.

---

### Facade

**Intent:** Provides a simplified interface to complex subsystems, shielding clients from intricate libraries or frameworks.

**Problem:** Business logic becomes tightly coupled to implementation details of third-party classes, making code hard to comprehend and maintain.

**When to Use:**
- Integrating with sophisticated libraries where you need only a fraction of functionality
- You want to shield client code from subsystem complexity
- Structuring systems into distinct layers with controlled communication points

**Key Components:**
- **Facade** - Offers simplified access by directing requests to appropriate subsystem objects
- **Complex Subsystem** - Contains numerous interdependent classes (unaware of facade)
- **Client** - Uses the facade rather than calling subsystem objects directly
- **Additional Facades** - Prevent a single facade from becoming overly complex (optional)

**Analogy:** A phone operator provides customers with a simple voice interface to ordering, payment, and delivery systems.

---

### Flyweight

**Intent:** Enables efficient memory usage by sharing common state across multiple objects rather than duplicating data in each instance.

**Problem:** Applications with vast quantities of similar objects consume excessive memory.

**When to Use:**
- Your program must support massive quantities of similar objects that strain available RAM
- Duplicate states can be extracted and shared

**Key Components:**
- **Flyweight** - Contains immutable intrinsic state shared across contexts
- **Context** - Holds extrinsic state unique to individual objects
- **Flyweight Factory** - Manages a pool of reusable flyweight instances
- **Client** - Calculates and stores extrinsic state, requesting flyweights through the factory

**Solution:** Separates unchanging data (intrinsic state) from contextual data (extrinsic state).

---

### Proxy

**Intent:** Provides a substitute or placeholder for another object, controlling access to the original.

**Problem:** Managing resource-heavy objects requires complex initialization logic that shouldn't be forced on clients.

**When to Use:**
- **Lazy initialization** - Delay creating expensive objects until needed
- **Access control** - Restrict which clients can use a service
- **Remote services** - Handle network communication details
- **Caching** - Store and reuse results from repeated requests
- **Logging/monitoring** - Track requests without modifying the original class

**Key Components:**
- **Service Interface** - Defines the contract both proxy and service implement
- **Real Service** - Provides actual business logic
- **Proxy** - Holds a reference to the service, performs additional operations, then delegates
- **Client** - Works with either proxy or service interchangeably via the shared interface

**Benefit:** The proxy manages the service's lifecycle and intercepts requests transparently.

---

## Behavioral Patterns

Behavioral patterns are concerned with algorithms and the assignment of responsibilities between objects.

### Chain of Responsibility

**Intent:** Passes requests along a chain of handlers, where each handler decides either to process the request or pass it to the next handler.

**Problem:** When multiple conditional checks need to execute in order (authentication, validation, caching), the code becomes bloated and difficult to maintain.

**When to Use:**
- Process requests with unknown types and sequences
- Execute handlers in a specific order
- Change handlers and their ordering dynamically at runtime

**Key Components:**
- **Handler Interface** - Declares the contract for processing requests
- **Base Handler** - Contains shared logic and maintains reference to next handler
- **Concrete Handlers** - Implement specific processing logic and decide whether to forward
- **Client** - Assembles the chain and triggers requests

**Mechanism:** Requests travel through a linked chain until a handler processes them or the chain ends.

---

### Command

**Intent:** Transforms requests into independent objects containing all request information, enabling parameterization, queuing, and undo operations.

**Problem:** GUI elements become tightly coupled to business logic. Creating numerous button subclasses for different behaviors leads to code duplication.

**When to Use:**
- **Parameterizing objects with operations** - Convert specific method calls into standalone objects
- **Queuing/scheduling** - Serialize commands for delayed or remote execution
- **Implementing undo/redo** - Maintain operation history with state backups

**Key Components:**
- **Command Interface** - Declares single execution method
- **Concrete Commands** - Implement specific operations, store parameters and receiver reference
- **Sender/Invoker** - Triggers commands without knowing implementation details
- **Receiver** - Contains actual business logic
- **Client** - Creates and configures command objects with receivers

**Example:** Text editor operations (copy, cut, paste, undo) invoked through toolbar buttons, context menus, or keyboard shortcuts.

---

### Iterator

**Intent:** Enables traversal of collection elements without revealing the underlying data structure representation.

**Problem:** Collections require flexible traversal methods, but adding multiple algorithms directly obscures the collection's primary responsibility.

**When to Use:**
- Collections have complex internal structures you want to hide
- You need multiple traversal algorithms for the same collection
- Code must work with various collection types unknown beforehand
- You want to reduce duplication of traversal code

**Key Components:**
- **Iterator Interface** - Declares traversal operations (fetch next, check remaining)
- **Concrete Iterators** - Implement specific traversal algorithms, track progress independently
- **Collection Interface** - Defines methods for obtaining compatible iterators
- **Concrete Collections** - Return iterator instances, maintain collection data
- **Client** - Works with collections and iterators through interfaces only

**Benefit:** Multiple iterators can traverse the same collection simultaneously with independent state.

---

### Mediator

**Intent:** Reduces chaotic dependencies between objects by restricting direct communication and forcing collaboration through a mediator intermediary.

**Problem:** Complex systems develop tangled relationships where components become tightly coupled. Changes to one element ripple through many others.

**When to Use:**
- Classes are heavily interdependent and hard to modify independently
- You need to reuse components in different contexts
- Creating numerous subclasses just to handle different interaction scenarios

**Key Components:**
- **Mediator Interface** - Declares notification method for components to communicate events
- **Concrete Mediator** - Manages component relationships and handles their interactions
- **Components** - Hold business logic but only reference the mediator interface
- **Communication Flow** - Components notify the mediator; mediator decides which components respond

**Benefit:** Components become loosely coupled, depending only on the mediator rather than dozens of colleagues.

---

### Memento

**Intent:** Saves and restores an object's previous state without exposing its internal implementation details.

**Problem:** Capturing object state for undo functionality while maintaining encapsulation. Direct field access violates encapsulation and creates fragile code.

**When to Use:**
- Implementing undo/redo functionality requiring state snapshots
- Transactions need rollback capability on errors
- Direct field access would compromise object encapsulation

**Key Components:**
- **Originator** - The object whose state needs preservation; creates mementos
- **Memento** - Immutable snapshot storing the originator's state
- **Caretaker** - Manages the history of mementos (typically a stack)

**Benefit:** Preserves encapsulation by making the originator responsible for its own snapshots.

---

### Observer

**Intent:** Establishes a subscription mechanism to notify multiple objects about events happening to the object they're observing.

**Problem:** The tension between efficiency and coupling. Instead of polling for updates (wasteful) or sending spam notifications (disruptive), create a structured notification system.

**When to Use:**
- Changes to one object require updating others, but affected objects aren't known in advance
- You need dynamic subscription management (objects can subscribe/unsubscribe at runtime)
- In GUI frameworks where user actions trigger multiple responses

**Key Components:**
- **Publisher** - Issues events and maintains a subscription list
- **Subscriber Interface** - Declares an `update()` method for receiving notifications
- **Concrete Subscribers** - Implement the interface to handle specific notifications
- **EventManager** - Manages the subscription list and notification distribution
- **Client** - Creates publishers and subscribers, establishing relationships

**Note:** Subscribers are notified in random order.

---

### State

**Intent:** Enables objects to alter their behavior when internal state changes, appearing as though the object's class has changed.

**Problem:** State machines implemented with extensive conditionals become difficult to maintain. Changes to transition logic may require modifying every method.

**When to Use:**
- Objects behave differently based on current state with enormous state counts
- State-specific code changes frequently
- Classes contain massive conditionals managing state-dependent behavior
- Similar states and transitions have duplicate code

**Key Components:**
- **Context** - Stores a reference to one concrete state object and delegates state-specific work
- **State Interface** - Declares methods representing state-specific behaviors
- **Concrete States** - Implement state-specific methods and can initiate transitions
- **State Transitions** - Context and concrete states can replace the current state object

**Example:** An audio player with Locked, Ready, and Playing states where button clicks produce different outcomes depending on current state.

---

### Strategy

**Intent:** Defines multiple algorithms, isolates each in separate classes, and swaps them interchangeably at runtime.

**Problem:** Classes become bloated with numerous conditional branches for different algorithmic variants. Adding new algorithms causes maintainability issues and merge conflicts.

**When to Use:**
- Need runtime algorithm switching within an object
- Multiple similar classes differing only in execution approach
- Want to isolate business logic from implementation details
- Have massive conditional statements selecting algorithm variants

**Key Components:**
- **Context** - Maintains a reference to a strategy object; delegates work via interface
- **Strategy Interface** - Declares the common execution method all strategies implement
- **Concrete Strategies** - Individual classes implementing different algorithm variations
- **Client** - Creates specific strategy objects and passes them to the context

**Benefit:** Eliminates conditional logic and enables extensibility without modifying existing code (Open/Closed Principle).

---

### Template Method

**Intent:** Establishes the skeleton of an algorithm in the superclass but lets subclasses override specific steps without altering the overall structure.

**Problem:** Addresses code duplication when multiple classes implement similar algorithms with minor variations.

**When to Use:**
- You want to let clients extend only particular algorithm steps, not the entire algorithm
- Multiple classes contain nearly identical algorithms with minor differences
- You need to eliminate code duplication across algorithm implementations

**Key Components:**
- **Abstract Base Class** - Declares the template method (algorithm skeleton) and abstract methods for individual steps
- **Concrete Subclasses** - Implement required abstract steps and may override optional ones
- **Steps** - Can be abstract (mandatory), have default implementations, or be hooks (optional extension points)

**Protection:** The template method itself cannot be overridden, ensuring the algorithm structure remains intact.

---

### Visitor

**Intent:** Separates algorithms from the objects on which they operate, allowing new behaviors to be added without modifying existing classes.

**Problem:** Adding functionality (like XML export) to existing class hierarchies without modifying fragile production code or scattering specialized logic across multiple classes.

**When to Use:**
- Performing operations across complex object structures with different element types
- Adding new behaviors without changing core classes
- Extracting auxiliary logic from primary classes

**Key Components:**
- **Visitor Interface** - Declares visiting methods for each concrete element type
- **Concrete Visitors** - Implement specific behaviors (e.g., XMLExportVisitor)
- **Element Interface** - Declares an `accept()` method to receive visitors
- **Concrete Elements** - Implement acceptance by redirecting to appropriate visitor methods

**Mechanism:** Objects accept a visitor and delegate to the correct visiting method via "double dispatch"—the element knows its own type and directs the visitor accordingly.

**Advantage:** Implements the Open/Closed Principle—add new operations without changing element classes.

---

## Summary

These 22 design patterns provide proven solutions to common software design problems:

- **Creational Patterns** (5) - Focus on object creation mechanisms
- **Structural Patterns** (7) - Deal with object composition and relationships
- **Behavioral Patterns** (10) - Handle communication between objects

Each pattern offers specific benefits and trade-offs. The key is selecting the appropriate pattern based on your specific requirements and constraints.

---

**Source:** This documentation is based on content from [Refactoring Guru Design Patterns Catalog](https://refactoring.guru/design-patterns/catalog)
