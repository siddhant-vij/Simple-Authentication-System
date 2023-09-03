# Simple Authentication System

A terminal-based authentication system designed to showcase registration, login, and password reset functionality using a CSV-based storage.

## Table of Contents

1. [Features](#features)
2. [Getting Started](#getting-started)
    - [Prerequisites](#prerequisites)
    - [Installation](#installation)
3. [Usage](#usage)
4. [Testing](#testing)
5. [Contributing](#contributing)
6. [Future Improvements](#future-improvements)
7. [License](#license)
8. [Acknowledgements](#acknowledgements)

<br>

## Features

- **User Authentication**: Register, log in, and reset passwords.
- **CSV-Based Storage**: User data is stored and retrieved from a CSV file.
- **Secure**: Passwords are hashed before being stored.
- **CLI Interface**: Clear menu-driven CLI interface to interact with the system.
- **Logout Feature**: Allow logged-in users to securely log out of the system.
- **Password Strength Checker**: Enforce users to choose strong passwords during registration or reset.
- **Forgot Password Mechanism**: Offer a mechanism for users to recover their password if forgotten.
- **Delete Account Option**: Allow users to delete their account and all associated data.

<br>

## Getting Started

### Prerequisites

- Dart SDK: Ensure you have the Dart SDK installed. If not, get it from [here](https://dart.dev/get-dart).

### Installation

1. Clone the repository:
    ```bash
    git clone https://github.com/siddhant-vij/Simple-Authentication-System.git
    ```

2. Navigate to the project directory and fetch the dependencies:
    ```bash
    cd Simple-Authentication-System
    dart pub get
    ```

<br>

## Usage

1. Start the application:
    ```bash
    dart run
    ```

2. Follow the on-screen instructions to register, log in, and reset passwords if needed. User data will be stored in a `users.csv` file within the project directory.

<br>

## Testing

This project comes with unit tests. To run them:

```bash
dart test
```

<br>

## Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. **Fork the Project**
2. **Create your Feature Branch**: 
    ```bash
    git checkout -b feature/AmazingFeature
    ```
3. **Commit your Changes**: 
    ```bash
    git commit -m 'Add some AmazingFeature'
    ```
4. **Push to the Branch**: 
    ```bash
    git push origin feature/AmazingFeature
    ```
5. **Open a Pull Request**

<br>

## Future Improvements

Below are some of the potential improvements and added functionalities that can enhance the Simple Authentication System:

**1. Data Encryption**: Encrypt the data in the CSV to ensure user data is secure even with direct file access.

**2. Multi-Factor Authentication**: Introduce an option for users to enable additional security layers for logging in.

**3. Lockout Mechanism**: Implement a system to deter brute-force attempts by locking out or delaying login after consecutive incorrect password attempts.

**4. Audit Log**: Maintain a log of all authentication activities for monitoring and security purposes.

**5. Backup and Recovery**: Design a backup mechanism to safeguard user data and ensure recovery options in case of system failures.

**6. Transition to a Relational Database**: Migrate from a CSV-based system to a more robust relational database like PostgreSQL or MySQL for better scalability, performance, and security.

**7. Database Backup**: Implement routine backups of the database to ensure data safety in case of unexpected failures.

**8. Data Validation and Sanitization**: Enhance the system to validate and sanitize inputs more thoroughly to protect against SQL injection and other potential threats, especially if moving to a more complex database system.


<br>

## License

Distributed under the MIT License. See [`LICENSE`](https://github.com/siddhant-vij/Simple-Authentication-System/blob/main/LICENSE) for more information.

<br>

## Acknowledgements

- [Dart Language](https://dart.dev/)
- [crypto package](https://pub.dev/packages/crypto)
- [csv package](https://pub.dev/packages/csv)