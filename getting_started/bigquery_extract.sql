EXPORT DATA OPTIONS(
uri='gs://{name_of_the_data_bucket}/events/events*.csv',
format='CSV',
header=true,
overwrite=true,
field_delimiter = ';') AS
SELECT * from looker-private-demo.ecomm.events;

EXPORT DATA OPTIONS(
uri='gs://{name_of_the_data_bucket}/distribution_centers/distribution_centers*.csv',
format='CSV',
header=true,
overwrite=true,
field_delimiter = ';') AS
SELECT * from looker-private-demo.ecomm.distribution_centers;

EXPORT DATA OPTIONS(
uri='gs://{name_of_the_data_bucket}/order_items/order_items*.csv',
format='CSV',
header=true,
overwrite=true,
field_delimiter = ';') AS
SELECT * from looker-private-demo.ecomm.order_items;

EXPORT DATA OPTIONS(
uri='gs://{name_of_the_data_bucket}/inventory_items/inventory_items*.csv',
format='CSV',
header=true,
overwrite=true,
field_delimiter = ';') AS
SELECT * from looker-private-demo.ecomm.inventory_items;

EXPORT DATA OPTIONS(
uri='gs://{name_of_the_data_bucket}/users/users*.csv',
format='CSV',
header=true,
overwrite=true,
field_delimiter = ';') AS
SELECT * from looker-private-demo.ecomm.users;

EXPORT DATA OPTIONS(
uri='gs://{name_of_the_data_bucket}/products/products*.csv',
format='CSV',
header=true,
overwrite=true,
field_delimiter = ';') AS
SELECT * from looker-private-demo.ecomm.products;

EXPORT DATA OPTIONS(
uri='gs://{name_of_the_data_bucket}/products/products*.csv',
format='CSV',
header=true,
overwrite=true,
field_delimiter = ';') AS
SELECT * from looker-private-demo.ecomm.products;
