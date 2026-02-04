---
name: PostgreSQL Table Design
description: Optimization guidelines for Order/Product schema. Covers normalization, data types, relationships, and indexing strategies.
source: wshobson/agents/postgresql-table-design
status: placeholder
---

# PostgreSQL Table Design

> **Status**: Value placeholder. Original source could not be fetched.
> **Goal**: Efficient and scalable database schema.

## Core Rules
1. **Normalization**: Aim for 3NF to reduce redundancy.
2. **Foreign Keys**: Enforce referential integrity.
3. **Data Types**: Use appropriate types (`uuid` for IDs, `timestamptz` for dates, `decimal` for money).
4. **Naming**: Use `snake_case` for tables and columns. Plural table names (e.g., `users`, `orders`).

## Specifics for E-commerce
- **Products**: Handle variants (sizes, colors) efficiently (JSONB vs separate tables).
- **Orders**: Snapshot prices at time of purchase (don't link to live product price).
- **Inventory**: Track stock levels accurately with concurrency controls.
