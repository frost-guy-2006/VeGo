import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

Deno.serve(async (req: Request) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // Initialize Supabase client with the Auth context of the user making the request.
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: { Authorization: req.headers.get('Authorization')! },
        },
      }
    );

    // Get the user from the token to ensure they are authenticated
    const { data: { user }, error: userError } = await supabaseClient.auth.getUser();
    if (userError || !user) {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), {
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // Parse the request body
    const body = await req.json();
    const { items, totalAmount, deliveryAddress, deliveryFee = 0.0 } = body;

    if (!items || !Array.isArray(items) || items.length === 0) {
      return new Response(JSON.stringify({ error: 'Cart is empty' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // Format the items for legacy JSONB column (Fallback support)
    const jsonbItems = items.map((item: any) => ({
      product: item.product,
      quantity: item.quantity,
      priceAtPurchase: item.priceAtPurchase,
    }));

    // Step 1: Insert into the orders table
    const { data: order, error: orderError } = await supabaseClient
      .from('orders')
      .insert({
        user_id: user.id,
        total_amount: totalAmount,
        status: 'pending',
        items: jsonbItems,
        delivery_fee: deliveryFee,
        delivery_address: deliveryAddress
      })
      .select()
      .single();

    if (orderError) {
      console.error('Error creating order:', orderError);
      return new Response(JSON.stringify({ error: 'Failed to create order' }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const orderId = order.id;

    // Step 2: Insert into relational order_items table
    const orderItemsData = items.map((item: any) => ({
      order_id: orderId,
      product_id: item.product.id,
      quantity: item.quantity,
      price_at_purchase: item.priceAtPurchase,
    }));

    const { error: itemsError } = await supabaseClient
      .from('order_items')
      .insert(orderItemsData);

    if (itemsError) {
      console.error('Warning: order_items insert failed:', itemsError);
      // We don't fail the whole request because JSONB fallback is there
    }

    // Step 3: Log the initial status in the audit table
    const { error: logError } = await supabaseClient
      .from('order_status_log')
      .insert({
        order_id: orderId,
        old_status: null,
        new_status: 'pending',
        changed_by: user.id,
      });

    if (logError) {
      console.error('Warning: order_status_log insert failed:', logError);
    }

    return new Response(JSON.stringify({ data: order }), {
      status: 200,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (error) {
    console.error('Internal Edge Function Error:', error);
    return new Response(JSON.stringify({ error: 'Internal Server Error' }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
