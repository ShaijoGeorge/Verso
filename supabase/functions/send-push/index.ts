import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import admin from "npm:firebase-admin@11.11.0"

interface ServiceAccount {
  projectId: string;
  clientEmail: string;
  privateKey: string;
  [key: string]: string;
}

if (admin.apps.length === 0) {
  const serviceAccountJson = Deno.env.get("FIREBASE_SERVICE_ACCOUNT")!;
  const serviceAccount = JSON.parse(serviceAccountJson) as ServiceAccount;

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}

serve(async (req: Request) => {
  try {
    const { fcm_token, title, body, type } = await req.json();

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // --- CASE A: TEST MESSAGE ---
    if (fcm_token) {
      const message = {
        token: fcm_token,
        notification: {
          title: title || "Test",
          body: body || "Test Notification",
        },
      };
      await admin.messaging().send(message);
      return new Response(JSON.stringify({ success: true }), { headers: { "Content-Type": "application/json" } });
    }

    // --- CASE B: GLOBAL DAILY REMINDER ---
    // Changed 'daily_verse' to 'daily_reminder'
    if (type === 'daily_reminder') {
      
      // 1. Fetch tokens
      const { data: profiles, error } = await supabase
        .from('profiles')
        .select('fcm_token')
        .not('fcm_token', 'is', null);

      if (error) throw error;

      const tokens = profiles.map(p => p.fcm_token);

      if (tokens.length === 0) {
        return new Response(JSON.stringify({ message: "No users found" }), { headers: { "Content-Type": "application/json" } });
      }

      // 2. Send "Time to Read" Message
      const message = {
        tokens: tokens,
        notification: {
          title: "📖 Time to Read",
          body: "Keep your streak alive! Take a moment to read a chapter today.",
        },
        // Clicking opens the app to the reading screen or home
        data: { route: "/home" } 
      };

      const batchResponse = await admin.messaging().sendEachForMulticast(message);
      
      return new Response(
        JSON.stringify({ 
          success: true, 
          successCount: batchResponse.successCount, 
          failureCount: batchResponse.failureCount 
        }),
        { headers: { "Content-Type": "application/json" } }
      );
    }

    return new Response(JSON.stringify({ error: "Invalid request" }), { status: 400 });

  } catch (error: any) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
});