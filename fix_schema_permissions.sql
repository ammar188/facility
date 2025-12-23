-- ============================================
-- Fix Schema-Level Permissions
-- This fixes "permission denied for schema public" error
-- ============================================

-- Step 1: Grant USAGE on public schema to authenticated role
GRANT USAGE ON SCHEMA public TO authenticated;

-- Step 2: Grant necessary permissions on ChatMessage table
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE "ChatMessage" TO authenticated;

-- Step 3: Grant permission to use sequences (for auto-increment IDs if any)
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO authenticated;

-- Step 4: Ensure RLS is enabled
ALTER TABLE "ChatMessage" ENABLE ROW LEVEL SECURITY;

-- Step 5: Drop and recreate policies to ensure they're correct
DROP POLICY IF EXISTS "Allow authenticated users to insert messages" ON "ChatMessage";
DROP POLICY IF EXISTS "Allow authenticated users to read messages" ON "ChatMessage";
DROP POLICY IF EXISTS "insert_policy" ON "ChatMessage";
DROP POLICY IF EXISTS "select_policy" ON "ChatMessage";

-- Step 6: Create INSERT policy
CREATE POLICY "Allow authenticated users to insert messages"
  ON "ChatMessage"
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Step 7: Create SELECT policy
CREATE POLICY "Allow authenticated users to read messages"
  ON "ChatMessage"
  FOR SELECT
  TO authenticated
  USING (true);

-- Step 8: Verify permissions
SELECT 
  'Schema Permissions' as check_type,
  nspname as schema_name,
  has_schema_privilege('authenticated', nspname, 'USAGE') as has_usage
FROM pg_namespace
WHERE nspname = 'public';

-- Step 9: Verify table permissions
SELECT 
  'Table Permissions' as check_type,
  tablename,
  has_table_privilege('authenticated', 'ChatMessage', 'INSERT') as can_insert,
  has_table_privilege('authenticated', 'SELECT') as can_select
FROM pg_tables
WHERE tablename = 'ChatMessage';

-- Step 10: Verify policies
SELECT 
  'Policies' as check_type,
  policyname,
  cmd as operation,
  roles
FROM pg_policies 
WHERE tablename = 'ChatMessage';

