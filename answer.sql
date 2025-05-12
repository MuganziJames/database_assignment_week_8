
-- Library Management System Database Schema

DROP DATABASE IF EXISTS library_mg;
CREATE DATABASE library_mg;
USE library_mg;

--  Table: Members

CREATE TABLE members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name      VARCHAR(50)  NOT NULL,
    last_name       VARCHAR(50)  NOT NULL,
    email           VARCHAR(100) NOT NULL UNIQUE,
    phone_number    VARCHAR(20),
    address         VARCHAR(200),
    date_of_birth   DATE,
    membership_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    membership_expiry DATE,
    membership_status ENUM('Active','Expired','Suspended') NOT NULL DEFAULT 'Active',
    total_checkouts INT UNSIGNED NOT NULL DEFAULT 0,
    outstanding_fines DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_member_email (email),
    INDEX idx_member_status (membership_status)
) ENGINE=InnoDB;


-- Table: Authors
CREATE TABLE authors (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name   VARCHAR(50) NOT NULL,
    last_name    VARCHAR(50) NOT NULL,
    birth_date   DATE,
    nationality  VARCHAR(50),
    biography    TEXT,
    created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_author_name (last_name, first_name)
) ENGINE=InnoDB;

-- Table: Publishers

CREATE TABLE publishers (
    publisher_id INT AUTO_INCREMENT PRIMARY KEY,
    name          VARCHAR(100) NOT NULL,
    address       VARCHAR(200),
    phone_number  VARCHAR(20),
    email         VARCHAR(100),
    website       VARCHAR(100),
    created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_publisher_name (name)
) ENGINE=InnoDB;

-- Table: Categories (self-referencing hierarchy)
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name               VARCHAR(50) NOT NULL,
    parent_category_id INT NULL,
    description        TEXT,
    created_at         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uq_category_name UNIQUE (name),
    CONSTRAINT fk_categories_parent
        FOREIGN KEY (parent_category_id)
        REFERENCES categories(category_id)
        ON DELETE SET NULL
) ENGINE=InnoDB;


-- Table: Books

CREATE TABLE books (
    book_id         INT AUTO_INCREMENT PRIMARY KEY,
    title           VARCHAR(200) NOT NULL,
    isbn            VARCHAR(20) UNIQUE,
    publisher_id    INT,
    publication_date DATE,
    edition         VARCHAR(20),
    language        VARCHAR(30) DEFAULT 'English',
    page_count      INT,
    description     TEXT,
    category_id     INT,
    dewey_decimal_number VARCHAR(20),
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_books_publisher
        FOREIGN KEY (publisher_id)
        REFERENCES publishers(publisher_id)
        ON DELETE SET NULL,
    CONSTRAINT fk_books_category
        FOREIGN KEY (category_id)
        REFERENCES categories(category_id)
        ON DELETE SET NULL,
    INDEX idx_book_title (title),
    INDEX idx_book_isbn  (isbn)
) ENGINE=InnoDB;


-- Table: Book_Authors  (Many-to-Many Books ↔ Authors)
   
CREATE TABLE book_authors (
    book_id     INT NOT NULL,
    author_id   INT NOT NULL,
    author_role ENUM('Primary','Co-author','Editor','Translator') DEFAULT 'Primary',
    created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (book_id, author_id),
    CONSTRAINT fk_bookauthors_book
        FOREIGN KEY (book_id)
        REFERENCES books(book_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_bookauthors_author
        FOREIGN KEY (author_id)
        REFERENCES authors(author_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;


--  Table: Book_Items (physical copies)
CREATE TABLE book_items (
    item_id     INT AUTO_INCREMENT PRIMARY KEY,
    book_id     INT NOT NULL,
    barcode     VARCHAR(50) NOT NULL UNIQUE,
    location    VARCHAR(50) NOT NULL,
    status      ENUM('Available','Checked Out','Reserved','Lost',
                     'Damaged','In Processing','In Transit')
                NOT NULL DEFAULT 'Available',
    acquisition_date DATE,
    price       DECIMAL(10,2),
    `condition` ENUM('New','Good','Fair','Poor') NOT NULL DEFAULT 'Good',
    notes       TEXT,
    created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_bookitems_book
        FOREIGN KEY (book_id)
        REFERENCES books(book_id)
        ON DELETE CASCADE,
    INDEX idx_item_barcode (barcode),
    INDEX idx_item_status  (status)
) ENGINE=InnoDB;


-- Table: Staff
CREATE TABLE staff (
    staff_id     INT AUTO_INCREMENT PRIMARY KEY,
    first_name   VARCHAR(50) NOT NULL,
    last_name    VARCHAR(50) NOT NULL,
    email        VARCHAR(100) NOT NULL UNIQUE,
    phone_number VARCHAR(20),
    `position`   VARCHAR(50) NOT NULL,
    department   VARCHAR(50),
    hire_date    DATE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    is_active    BOOLEAN NOT NULL DEFAULT TRUE,
    last_login   DATETIME,
    created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_staff_email (email)
) ENGINE=InnoDB;


-- Table: Loans (check-outs)

CREATE TABLE loans (
    loan_id          INT AUTO_INCREMENT PRIMARY KEY,
    item_id          INT NOT NULL,
    member_id        INT NOT NULL,
    checkout_date    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    due_date         DATETIME NOT NULL,
    return_date      DATETIME,
    renewal_count    INT UNSIGNED NOT NULL DEFAULT 0,
    fine_amount      DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    fine_paid        BOOLEAN NOT NULL DEFAULT FALSE,
    checkout_staff_id INT,
    return_staff_id   INT,
    status ENUM('Active','Returned','Overdue','Lost') NOT NULL DEFAULT 'Active',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_loans_item
        FOREIGN KEY (item_id)
        REFERENCES book_items(item_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_loans_member
        FOREIGN KEY (member_id)
        REFERENCES members(member_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_loans_checkout_staff
        FOREIGN KEY (checkout_staff_id)
        REFERENCES staff(staff_id)
        ON DELETE SET NULL,
    CONSTRAINT fk_loans_return_staff
        FOREIGN KEY (return_staff_id)
        REFERENCES staff(staff_id)
        ON DELETE SET NULL,
    INDEX idx_loan_status  (status),
    INDEX idx_loan_due_date(due_date)
) ENGINE=InnoDB;


-- Table: Reservations

CREATE TABLE reservations (
    reservation_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id     INT NOT NULL,
    member_id   INT NOT NULL,
    reservation_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expiry_date DATETIME NOT NULL,
    fulfillment_date DATETIME,
    status ENUM('Pending','Fulfilled','Cancelled','Expired') NOT NULL DEFAULT 'Pending',
    notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_reservations_book
        FOREIGN KEY (book_id)
        REFERENCES books(book_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_reservations_member
        FOREIGN KEY (member_id)
        REFERENCES members(member_id)
        ON DELETE CASCADE,
    INDEX idx_reservation_status (status)
) ENGINE=InnoDB;


-- Table: Fines

CREATE TABLE fines (
    fine_id      INT AUTO_INCREMENT PRIMARY KEY,
    loan_id      INT NOT NULL,
    member_id    INT NOT NULL,
    fine_amount  DECIMAL(10,2) NOT NULL,
    fine_date    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    payment_date TIMESTAMP NULL,
    payment_amount DECIMAL(10,2),
    fine_reason ENUM('Overdue','Damaged','Lost') NOT NULL,
    status ENUM('Pending','Paid','Waived') NOT NULL DEFAULT 'Pending',
    staff_id INT,
    notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_fines_loan
        FOREIGN KEY (loan_id)   REFERENCES loans(loan_id)   ON DELETE CASCADE,
    CONSTRAINT fk_fines_member
        FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE,
    CONSTRAINT fk_fines_staff
        FOREIGN KEY (staff_id)  REFERENCES staff(staff_id)  ON DELETE SET NULL,
    INDEX idx_fine_status (status)
) ENGINE=InnoDB;


-- Table: Library Events

CREATE TABLE library_events (
    event_id     INT AUTO_INCREMENT PRIMARY KEY,
    title        VARCHAR(200) NOT NULL,
    description  TEXT,
    event_date   DATETIME NOT NULL,
    duration     INT,            -- minutes
    location     VARCHAR(100),
    max_attendees INT,
    current_attendees INT NOT NULL DEFAULT 0,
    event_type ENUM('Book Club','Workshop','Author Visit','Story Time',
                    'Exhibition','Other') NOT NULL,
    is_public BOOLEAN NOT NULL DEFAULT TRUE,
    staff_id INT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_events_staff
        FOREIGN KEY (staff_id)
        REFERENCES staff(staff_id)
        ON DELETE SET NULL,
    INDEX idx_event_date (event_date)
) ENGINE=InnoDB;

-- Table: Event Registrations (Members ↔ Events)

CREATE TABLE event_registrations (
    registration_id INT AUTO_INCREMENT PRIMARY KEY,
    event_id   INT NOT NULL,
    member_id  INT NOT NULL,
    registration_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    attendance_status ENUM('Registered','Attended','No-Show','Cancelled')
                      NOT NULL DEFAULT 'Registered',
    notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_registration_event
        FOREIGN KEY (event_id)
        REFERENCES library_events(event_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_registration_member
        FOREIGN KEY (member_id)
        REFERENCES members(member_id)
        ON DELETE CASCADE,
    UNIQUE KEY uq_event_member (event_id, member_id),
    INDEX idx_registration_status (attendance_status)
) ENGINE=InnoDB;


-- Table: Feedback

CREATE TABLE feedback (
    feedback_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id   INT,
    book_id     INT,
    rating      TINYINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review      TEXT,
    feedback_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_public   BOOLEAN NOT NULL DEFAULT FALSE,
    is_approved BOOLEAN NOT NULL DEFAULT FALSE,
    staff_id    INT,
    created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_feedback_member
        FOREIGN KEY (member_id)
        REFERENCES members(member_id)
        ON DELETE SET NULL,
    CONSTRAINT fk_feedback_book
        FOREIGN KEY (book_id)
        REFERENCES books(book_id)
        ON DELETE SET NULL,
    CONSTRAINT fk_feedback_staff
        FOREIGN KEY (staff_id)
        REFERENCES staff(staff_id)
        ON DELETE SET NULL
) ENGINE=InnoDB;


-- Table: System Logs (audit)

CREATE TABLE system_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    action_type        VARCHAR(50) NOT NULL,
    action_description TEXT NOT NULL,
    entity_type        VARCHAR(50) NOT NULL,
    entity_id          INT NOT NULL,
    staff_id           INT,
    ip_address         VARCHAR(50),
    user_agent         TEXT,
    created_at         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_logs_staff
        FOREIGN KEY (staff_id)
        REFERENCES staff(staff_id)
        ON DELETE SET NULL,
    INDEX idx_log_action (action_type),
    INDEX idx_log_entity (entity_type, entity_id)
) ENGINE=InnoDB;
