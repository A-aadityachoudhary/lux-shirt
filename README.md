# README


Here I have create required models (in model branch).
Models are - Admin, User, Product, Order, Order_item, Payment, Category.

```
rails generate model User name:string email:string password:string role:string

rails generate model Admin user:references

rails generate model Category name:string

rails generate model Product title:string description:text price:decimal stock:integer category:references admin:references 

rails generate model Order user:references total_amount:decimal status:string

rails generate model OrderItem order:references product:references quantity:integer

rails generate model Payment order:references total_amount:decimal

```
