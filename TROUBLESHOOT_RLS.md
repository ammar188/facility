# Troubleshooting RLS Permission Denied Error

## Error: `permission denied for table Conversation, code: 42501`

This error means Row Level Security (RLS) is blocking the INSERT operation.

## Step-by-Step Fix:

### 1. **Run the Simple SQL Script**

Open Supabase SQL Editor and run `fix_conversation_rls_simple.sql` - this is a cleaner version that should work.

### 2. **Verify You're Logged In**

Make sure you're authenticated in your Flutter app. Check:
- User is logged in
- Session is valid
- `auth.uid()` returns your user ID

### 3. **Check Table Name Case**

In Supabase, table names can be case-sensitive. Try both:
- `Conversation` (capital C)
- `conversation` (lowercase)

### 4. **Manual Test in Supabase**

Try inserting a conversation manually in Supabase SQL Editor:

```sql
-- First, check your user ID
SELECT auth.uid() as current_user_id;

-- Then try to insert (replace YOUR_USER_ID with actual UUID)
INSERT INTO public."Conversation" (user_id, vendor_id)
VALUES (auth.uid(), auth.uid())
RETURNING id, user_id, vendor_id;
```

If this works, the issue is in the Flutter code.
If this fails, the RLS policies need to be fixed.

### 5. **Check Existing Policies**

Run this to see what policies exist:

```sql
SELECT 
  policyname,
  cmd as operation,
  qual as using_expression,
  with_check as check_expression
FROM pg_policies
WHERE tablename = 'Conversation';
```

### 6. **Temporary Bypass (For Testing Only)**

If you need to test quickly, you can temporarily disable RLS:

```sql
-- WARNING: Only for testing! Re-enable RLS after testing
ALTER TABLE public."Conversation" DISABLE ROW LEVEL SECURITY;
```

Then test your app. If it works, the issue is definitely RLS policies.
**Remember to re-enable RLS after testing!**

### 7. **Re-enable RLS After Testing**

```sql
ALTER TABLE public."Conversation" ENABLE ROW LEVEL SECURITY;
```

Then run the `fix_conversation_rls_simple.sql` script again.

## Common Issues:

1. **Policy syntax error**: Make sure the USING and WITH CHECK clauses are correct
2. **Table name case**: Use exact case as in Supabase dashboard
3. **User not authenticated**: Make sure `auth.uid()` returns a value
4. **Missing GRANT statements**: Need to grant permissions to `authenticated` role

## What to Share for Help:

1. Output of: `SELECT auth.uid();` (your user ID)
2. Output of the policies query (step 5)
3. Whether manual insert works (step 4)
4. Browser console errors when sending message

