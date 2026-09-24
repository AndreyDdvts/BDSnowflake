-- Dates
create table if not exists dim_date (
    date_key        int primary key,
    date_actual     date not null unique,
    year            int not null,
    quarter         int not null,
    month           int not null,
    day             int not null,
    week_of_year    int not null,
    is_weekend      boolean not null
);

-- Geography
create table if not exists dim_geo_country (
    country_key serial primary key,
    country_name text not null unique
);

create table if not exists dim_geo_state (
    state_key serial primary key,
    state_name text,
    country_key int not null references dim_geo_country(country_key) on delete restrict,
    constraint uq_state unique (country_key, state_name)
);

create table if not exists dim_geo_city (
    city_key serial primary key,
    city_name text not null,
    state_key int references dim_geo_state(state_key) on delete set null,
    country_key int not null references dim_geo_country(country_key) on delete restrict,
    constraint uq_city unique (country_key, state_key, city_name)
);

create table if not exists dim_geo_postal (
    postal_key serial primary key,
    postal_code text not null,
    country_key int not null references dim_geo_country(country_key) on delete restrict,
    constraint uq_postal unique (country_key, postal_code)
);

-- Pets
create table if not exists dim_pet_category (
    pet_category_key serial primary key,
    pet_category text not null unique
);

create table if not exists dim_pet_type (
    pet_type_key serial primary key,
    pet_type text not null,
    pet_category_key int references dim_pet_category(pet_category_key) on delete set null,
    constraint uq_pet_type unique (pet_type, pet_category_key)
);

create table if not exists dim_pet_breed (
    pet_breed_key serial primary key,
    pet_breed text not null,
    pet_type_key int references dim_pet_type(pet_type_key) on delete set null,
    constraint uq_pet_breed unique (pet_breed, pet_type_key)
);

create table if not exists dim_pet (
    pet_key serial primary key,
    pet_name text,
    pet_breed_key int references dim_pet_breed(pet_breed_key) on delete set null
);

-- Parties
create table if not exists dim_customer (
    customer_key serial primary key,
    customer_natural_id int,
    first_name text,
    last_name text,
    age int,
    email text unique,
    postal_key int references dim_geo_postal(postal_key) on delete set null,
    pet_key int references dim_pet(pet_key) on delete set null
);

create table if not exists dim_seller (
    seller_key serial primary key,
    seller_natural_id int,
    first_name text,
    last_name text,
    email text unique,
    postal_key int references dim_geo_postal(postal_key) on delete set null
);

create table if not exists dim_store (
    store_key serial primary key,
    store_name text not null unique,
    location text,
    city_key int references dim_geo_city(city_key) on delete set null,
    state_key int references dim_geo_state(state_key) on delete set null,
    country_key int references dim_geo_country(country_key) on delete set null,
    phone text,
    email text
);

create table if not exists dim_supplier (
    supplier_key serial primary key,
    supplier_name text not null unique,
    contact text,
    email text,
    phone text,
    address text,
    city_key int references dim_geo_city(city_key) on delete set null,
    country_key int references dim_geo_country(country_key) on delete set null
);

-- Product
create table if not exists dim_brand (
    brand_key serial primary key,
    brand_name text not null unique
);

create table if not exists dim_category (
    category_key serial primary key,
    category_name text not null unique
);

create table if not exists dim_color (
    color_key serial primary key,
    color_name text not null unique
);

create table if not exists dim_size (
    size_key serial primary key,
    size_name text not null unique
);

create table if not exists dim_material (
    material_key serial primary key,
    material_name text not null unique
);

create table if not exists dim_product (
    product_key serial primary key,
    product_natural_id int unique,
    product_name text not null,
    brand_key int references dim_brand(brand_key) on delete set null,
    category_key int references dim_category(category_key) on delete set null,
    color_key int references dim_color(color_key) on delete set null,
    size_key int references dim_size(size_key) on delete set null,
    material_key int references dim_material(material_key) on delete set null,
    weight numeric(12,3),
    description text,
    rating numeric(5,2),
    reviews int,
    release_date_key int references dim_date(date_key) on delete set null,
    expiry_date_key int references dim_date(date_key) on delete set null
);

create table if not exists bridge_product_supplier (
    product_key int not null references dim_product(product_key) on delete cascade,
    supplier_key int not null references dim_supplier(supplier_key) on delete cascade,
    primary key (product_key, supplier_key)
);

-- Fact
create table if not exists fact_sales (
    sales_key bigserial primary key,
    sale_date_key int not null references dim_date(date_key) on delete restrict,
    customer_key int references dim_customer(customer_key) on delete set null,
    seller_key int references dim_seller(seller_key) on delete set null,
    product_key int references dim_product(product_key) on delete set null,
    store_key int references dim_store(store_key) on delete set null,
    supplier_key int references dim_supplier(supplier_key) on delete set null,
    sale_id int,
    quantity int not null,
    line_total numeric(18,2) not null,
    unit_price numeric(18,2),
    created_at timestamptz default now()
);