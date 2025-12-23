# Chat Troubleshooting Guide

## Common Issues and Solutions

### 1. **Permission Denied Errors**

**Error:** `permission denied for table Conversation` or `42501`

**Solution:**
- Run the SQL script `fix_conversation_rls_permissions.sql` in Supabase SQL Editor
- Make sure you're logged in as an authenticated user
- Verify RLS policies are created correctly

### 2. **Messages Not Appearing**

**Possible Causes:**
- Conversation not created in database
- Messages table (`ConversationMessage`) missing RLS policies
- Real-time subscriptions not working

**Solution:**
- Check browser console for errors
- Verify conversation exists in Supabase dashboard
- Check if messages are being inserted into `ConversationMessage` table

### 3. **Chat Not Loading**

**Possible Causes:**
- No conversation exists for the user
- RLS policies blocking SELECT queries
- Table name mismatch (case sensitivity)

**Solution:**
- Run `ensureDefaultChat()` on screen load
- Verify table name is exactly `Conversation` (capital C)
- Check RLS policies allow SELECT for authenticated users

### 4. **Table Name Issues**

**Current Schema:**
- `Conversation` table: `id`, `user_id`, `vendor_id`, `created_at`, `updated_at`
- `ConversationMessage` table: `id`, `chat_id`, `sender_id`, `content`, `created_at`

**Important:** Table names are case-sensitive in Supabase. Make sure:
- `Conversation` (capital C) - not `conversation`
- `ConversationMessage` (capital C, capital M) - not `conversation_message` or `ConversationMessages`

## Debugging Steps

1. **Check Browser Console:**
   - Look for errors when sending messages
   - Check network tab for failed requests
   - Verify authentication status

2. **Check Supabase Dashboard:**
   - Verify `Conversation` table exists with correct schema
   - Verify `ConversationMessage` table exists
   - Check RLS policies are enabled and correct
   - Verify data is being inserted

3. **Test Database Queries:**
   - Try inserting a conversation manually in Supabase
   - Try inserting a message manually
   - Check if SELECT queries work

## Required RLS Policies

### For `Conversation` table:
- SELECT: Users can view where `user_id = auth.uid()`
- INSERT: Users can create where `user_id = auth.uid()`
- UPDATE: Users can update where `user_id = auth.uid()`

### For `ConversationMessage` table:
- SELECT: Users can view messages in their conversations
- INSERT: Users can send messages
- UPDATE: Users can update their own messages (optional)

## Next Steps

If chat is still not working:
1. Share the exact error message from browser console
2. Check if conversation is created in Supabase
3. Verify RLS policies are set up correctly
4. Check if messages table has proper RLS policies

