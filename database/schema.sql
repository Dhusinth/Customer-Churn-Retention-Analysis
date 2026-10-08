CREATE DATABASE IF NOT EXISTS customer_churn_analysis;
USE customer_churn_analysis;

DROP TABLE IF EXISTS customer_activity;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS subscriptions;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    gender VARCHAR(20),
    age INT,
    city VARCHAR(100),
    state VARCHAR(100),
    signup_date DATE
);

CREATE TABLE subscriptions (
    subscription_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    plan VARCHAR(30) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NULL,
    monthly_charge DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE payments (
    payment_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    payment_date DATE NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(30) NOT NULL,
    payment_status VARCHAR(20) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE customer_activity (
    activity_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    activity_date DATE NOT NULL,
    login_count INT NOT NULL,
    support_tickets INT NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
