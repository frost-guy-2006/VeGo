---
name: Supabase Best Practices
description: Official skill for RLS & Edge Functions. Covers Row Level Security policies, database optimization, and secure backend patterns.
source: supabase/agent-skills/supabase-postgres-best-practices
status: placeholder
---

# Supabase Best Practices

> **Status**: Value placeholder. Original source could not be fetched.
> **Goal**: Secure and optimized Supabase implementation.

## Row Level Security (RLS)
- **Enable RLS**: Always enable RLS on public tables.
- **Policies**: Define strict `SELECT`, `INSERT`, `UPDATE`, `DELETE` policies.
- **Service Role**: Use service role keys only in secure server environments (Edge Functions), never in client app.

## Database Optimization
- **Indexes**: Add indexes on frequently queried columns (esp. foreign keys).
- **Functions**: Use Postgres functions (RPC) for complex logic.
- **Triggers**: Use triggers for automated data integrity (e.g., `updated_at`).

## Edge Functions
- Keep them small and focused (SRP).
- Validate inputs rigorously.
- Handle CORS properly.
