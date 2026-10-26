<?php
/**
 * Plugin Name: Magna Store API
 * Description: Authenticated mobile API for the Magna Data Store Flutter app.
 * Version: 1.0.0
 */

if (!defined('ABSPATH')) {
    exit;
}

add_action('rest_api_init', 'magna_store_register_routes');

function magna_store_register_routes() {
    register_rest_route('magna/v1', '/auth/register', array(
        'methods' => WP_REST_Server::CREATABLE,
        'callback' => 'magna_store_register',
        'permission_callback' => '__return_true',
    ));

    register_rest_route('magna/v1', '/auth/login', array(
        'methods' => WP_REST_Server::CREATABLE,
        'callback' => 'magna_store_login',
        'permission_callback' => '__return_true',
    ));

    register_rest_route('magna/v1', '/auth/logout', array(
        'methods' => WP_REST_Server::CREATABLE,
        'callback' => 'magna_store_logout',
        'permission_callback' => 'magna_store_authenticated',
    ));

    register_rest_route('magna/v1', '/auth/me', array(
        array(
            'methods' => WP_REST_Server::READABLE,
            'callback' => 'magna_store_me',
            'permission_callback' => 'magna_store_authenticated',
        ),
        array(
            'methods' => WP_REST_Server::EDITABLE,
            'callback' => 'magna_store_update_me',
            'permission_callback' => 'magna_store_authenticated',
        ),
    ));

    register_rest_route('magna/v1', '/auth/forgot-password', array(
        'methods' => WP_REST_Server::CREATABLE,
        'callback' => 'magna_store_forgot_password',
        'permission_callback' => '__return_true',
    ));

    register_rest_route('magna/v1', '/auth/reset-password', array(
        'methods' => WP_REST_Server::CREATABLE,
        'callback' => 'magna_store_reset_password',
        'permission_callback' => '__return_true',
    ));

    register_rest_route('magna/v1', '/orders', array(
        'methods' => WP_REST_Server::READABLE,
        'callback' => 'magna_store_orders',
        'permission_callback' => 'magna_store_authenticated',
        'args' => array(
            'page' => array('type' => 'integer', 'default' => 1, 'minimum' => 1),
            'per_page' => array('type' => 'integer', 'default' => 10, 'minimum' => 1, 'maximum' => 50),
            'status' => array('type' => 'string', 'default' => ''),
        ),
    ));

    register_rest_route('magna/v1', '/orders/(?P<id>\d+)', array(
        'methods' => WP_REST_Server::READABLE,
        'callback' => 'magna_store_order',
        'permission_callback' => 'magna_store_authenticated',
    ));

    register_rest_route('magna/v1', '/addresses', array(
        array(
            'methods' => WP_REST_Server::READABLE,
            'callback' => 'magna_store_addresses',
            'permission_callback' => 'magna_store_authenticated',
        ),
        array(
            'methods' => WP_REST_Server::CREATABLE,
            'callback' => 'magna_store_create_address',
            'permission_callback' => 'magna_store_authenticated',
        ),
    ));

    register_rest_route('magna/v1', '/addresses/(?P<id>\d+)', array(
        array(
            'methods' => WP_REST_Server::EDITABLE,
            'callback' => 'magna_store_update_address',
            'permission_callback' => 'magna_store_authenticated',
        ),
        array(
            'methods' => WP_REST_Server::DELETABLE,
            'callback' => 'magna_store_delete_address',
            'permission_callback' => 'magna_store_authenticated',
        ),
    ));

    register_rest_route('magna/v1', '/addresses/(?P<id>\d+)/default', array(
        'methods' => WP_REST_Server::EDITABLE,
        'callback' => 'magna_store_default_address',
        'permission_callback' => 'magna_store_authenticated',
    ));

    register_rest_route('magna/v1', '/notifications/devices/register', array(
        'methods' => WP_REST_Server::CREATABLE,
        'callback' => 'magna_store_register_device',
        'permission_callback' => 'magna_store_authenticated',
    ));

    register_rest_route('magna/v1', '/checkout/create-order', array(
        'methods' => WP_REST_Server::CREATABLE,
        'callback' => 'magna_store_create_cod_order',
        'permission_callback' => 'magna_store_authenticated',
    ));

    register_rest_route('magna/v1', '/payments/create-order', array(
        'methods' => WP_REST_Server::CREATABLE,
        'callback' => 'magna_store_create_payment_order',
        'permission_callback' => 'magna_store_authenticated',
    ));

    register_rest_route('magna/v1', '/payments/verify', array(
        'methods' => WP_REST_Server::CREATABLE,
        'callback' => 'magna_store_verify_payment',
        'permission_callback' => 'magna_store_authenticated',
    ));

    register_rest_route('magna/v1', '/payments/phonepe/create', array(
        'methods' => WP_REST_Server::CREATABLE,
        'callback' => 'magna_store_create_phonepe_payment',
        'permission_callback' => 'magna_store_authenticated',
    ));

    register_rest_route('magna/v1', '/payments/phonepe/status/(?P<id>\d+)', array(
        'methods' => WP_REST_Server::READABLE,
        'callback' => 'magna_store_phonepe_status',
        'permission_callback' => 'magna_store_authenticated',
    ));

    register_rest_route('magna/v1', '/payments/phonepe/webhook', array(
        'methods' => WP_REST_Server::CREATABLE,
        'callback' => 'magna_store_phonepe_webhook',
        'permission_callback' => '__return_true',
    ));

    register_rest_route('magna/v1', '/payments/(?P<id>\d+)/invoice/email', array(
        'methods' => WP_REST_Server::CREATABLE,
        'callback' => 'magna_store_email_invoice',
        'permission_callback' => 'magna_store_authenticated',
    ));
}

function magna_store_authenticated() {
    return magna_store_current_user() ? true : new WP_Error(
        'magna_auth_required',
        'Authentication is required.',
        array('status' => 401)
    );
}

function magna_store_current_user() {
    $authorization = isset($_SERVER['HTTP_AUTHORIZATION'])
        ? sanitize_text_field(wp_unslash($_SERVER['HTTP_AUTHORIZATION']))
        : '';

    if (!preg_match('/^Bearer\s+(.+)$/i', $authorization, $matches)) {
        return false;
    }

    $token_hash = hash('sha256', trim($matches[1]));
    $user_id = (int) get_transient('magna_store_token_' . $token_hash);

    if ($user_id <= 0) {
        return false;
    }

    $user = get_user_by('id', $user_id);
    return $user && $user->exists() ? $user : false;
}

function magna_store_issue_token($user_id) {
    $token = wp_generate_password(64, false, false);
    $hash = hash('sha256', $token);
    set_transient('magna_store_token_' . $hash, (int) $user_id, 30 * DAY_IN_SECONDS);
    return $token;
}

function magna_store_revoke_token() {
    $authorization = isset($_SERVER['HTTP_AUTHORIZATION'])
        ? sanitize_text_field(wp_unslash($_SERVER['HTTP_AUTHORIZATION']))
        : '';
    if (preg_match('/^Bearer\s+(.+)$/i', $authorization, $matches)) {
        delete_transient('magna_store_token_' . hash('sha256', trim($matches[1])));
    }
}

function magna_store_user_response($user, $token = '') {
    $response = array(
        'id' => (int) $user->ID,
        'email' => (string) $user->user_email,
        'full_name' => trim($user->first_name . ' ' . $user->last_name),
        'phone' => (string) get_user_meta($user->ID, 'billing_phone', true),
        'is_active' => true,
        'is_verified' => true,
    );
    if ($token !== '') {
        $response['access_token'] = $token;
        $response['token_type'] = 'bearer';
        $response['expires_in'] = 30 * DAY_IN_SECONDS;
    }
    return $response;
}

function magna_store_request_body($request) {
    $body = $request->get_json_params();
    return is_array($body) ? $body : array();
}

function magna_store_register($request) {
    $body = magna_store_request_body($request);
    $email = sanitize_email($body['email'] ?? '');
    $password = (string) ($body['password'] ?? '');

    if (!is_email($email) || strlen($password) < 12) {
        return new WP_Error('magna_invalid_registration', 'Use a valid email and a password of at least 12 characters.', array('status' => 422));
    }
    if (email_exists($email)) {
        return new WP_Error('magna_email_exists', 'An account with this email already exists.', array('status' => 409));
    }

    $user_id = wc_create_new_customer($email, '', $password);
    if (is_wp_error($user_id)) {
        return new WP_Error('magna_registration_failed', 'Unable to create the account.', array('status' => 400));
    }

    $full_name = sanitize_text_field($body['full_name'] ?? '');
    if ($full_name !== '') {
        update_user_meta($user_id, 'billing_first_name', strtok($full_name, ' '));
        update_user_meta($user_id, 'billing_last_name', trim(substr($full_name, strlen(strtok($full_name, ' ')))));
    }
    if (!empty($body['phone'])) {
        update_user_meta($user_id, 'billing_phone', sanitize_text_field($body['phone']));
    }

    return new WP_REST_Response(magna_store_user_response(get_user_by('id', $user_id)), 201);
}

function magna_store_login($request) {
    $body = magna_store_request_body($request);
    $email = sanitize_email($body['email'] ?? '');
    $password = (string) ($body['password'] ?? '');
    $user = get_user_by('email', $email);
    $authenticated = $user ? wp_authenticate($user->user_login, $password) : new WP_Error('invalid', 'invalid');

    if (is_wp_error($authenticated)) {
        return new WP_Error('magna_invalid_login', 'Invalid email or password.', array('status' => 401));
    }

    return magna_store_user_response($user, magna_store_issue_token($user->ID));
}

function magna_store_logout() {
    magna_store_revoke_token();
    return array('status' => 'logged_out');
}

function magna_store_me() {
    return magna_store_user_response(magna_store_current_user());
}

function magna_store_update_me($request) {
    $user = magna_store_current_user();
    $body = magna_store_request_body($request);
    $full_name = sanitize_text_field($body['full_name'] ?? '');
    $phone = sanitize_text_field($body['phone'] ?? '');

    if ($full_name !== '') {
        $parts = preg_split('/\s+/', $full_name, 2);
        update_user_meta($user->ID, 'billing_first_name', $parts[0]);
        update_user_meta($user->ID, 'billing_last_name', $parts[1] ?? '');
    }
    update_user_meta($user->ID, 'billing_phone', $phone);
    return magna_store_user_response(get_user_by('id', $user->ID));
}

function magna_store_forgot_password($request) {
    $body = magna_store_request_body($request);
    $email = sanitize_email($body['email'] ?? '');
    $user = get_user_by('email', $email);
    if ($user) {
        retrieve_password($user->user_login);
    }
    return array('status' => 'accepted');
}

function magna_store_reset_password($request) {
    $body = magna_store_request_body($request);
    $user = check_password_reset_key(
        sanitize_text_field($body['key'] ?? ''),
        sanitize_text_field($body['login'] ?? '')
    );
    if (is_wp_error($user)) {
        return new WP_Error('magna_invalid_reset', 'The reset link is invalid or expired.', array('status' => 400));
    }
    $password = (string) ($body['password'] ?? '');
    if (strlen($password) < 12) {
        return new WP_Error('magna_invalid_password', 'Password must be at least 12 characters.', array('status' => 422));
    }
    reset_password($user, $password);
    return array('status' => 'reset');
}

function magna_store_orders($request) {
    $user = magna_store_current_user();
    $page = max(1, (int) $request->get_param('page'));
    $per_page = min(50, max(1, (int) $request->get_param('per_page')));
    $status = sanitize_key((string) $request->get_param('status'));
    $args = array(
        'customer_id' => $user->ID,
        'limit' => $per_page,
        'paged' => $page,
        'orderby' => 'date',
        'order' => 'DESC',
        'paginate' => true,
    );
    if ($status !== '' && array_key_exists('wc-' . $status, wc_get_order_statuses())) {
        $args['status'] = array('wc-' . $status);
    }
    $results = wc_get_orders($args);
    $items = array();
    foreach ($results->orders as $order) {
        $items[] = magna_store_format_order($order, false);
    }
    $response = rest_ensure_response(array(
        'items' => $items,
        'total' => (int) $results->total,
        'total_pages' => (int) $results->max_num_pages,
    ));
    $response->header('Cache-Control', 'no-store');
    return $response;
}

function magna_store_order($request) {
    $order = wc_get_order((int) $request['id']);
    $user = magna_store_current_user();
    if (!$order || (int) $order->get_customer_id() !== (int) $user->ID) {
        return new WP_Error('magna_order_not_found', 'Order not found.', array('status' => 404));
    }
    return magna_store_format_order($order, true);
}

function magna_store_format_order($order, $detail) {
    $items = array();
    foreach ($order->get_items() as $item) {
        $product = $item->get_product();
        $items[] = array(
            'id' => (int) $item->get_id(),
            'product_id' => (int) $item->get_product_id(),
            'variation_id' => (int) $item->get_variation_id(),
            'name' => (string) $item->get_name(),
            'quantity' => (int) $item->get_quantity(),
            'subtotal' => (int) round((float) $item->get_subtotal() * 100),
            'total' => (int) round((float) $item->get_total() * 100),
            'sku' => $product ? (string) $product->get_sku() : '',
            'image' => '',
        );
    }
    $created = $order->get_date_created();
    $result = array(
        'id' => (int) $order->get_id(),
        'number' => (string) $order->get_order_number(),
        'status' => (string) $order->get_status(),
        'status_label' => (string) wc_get_order_status_name($order->get_status()),
        'date_created' => $created ? $created->date('c') : '',
        'currency' => array(
            'currency_code' => (string) $order->get_currency(),
            'currency_symbol' => (string) get_woocommerce_currency_symbol($order->get_currency()),
            'currency_minor_unit' => wc_get_price_decimals(),
            'currency_decimal_separator' => wc_get_price_decimal_separator(),
            'currency_thousand_separator' => wc_get_price_thousand_separator(),
            'currency_prefix' => '',
            'currency_suffix' => '',
        ),
        'total' => (int) round((float) $order->get_total() * 100),
        'item_count' => (int) $order->get_item_count(),
        'items' => $items,
        'tracking' => array(),
    );
    if ($detail) {
        $result['subtotal'] = (int) round((float) $order->get_subtotal() * 100);
        $result['discount_total'] = (int) round((float) $order->get_discount_total() * 100);
        $result['shipping_total'] = (int) round((float) $order->get_shipping_total() * 100);
        $result['tax_total'] = (int) round((float) $order->get_total_tax() * 100);
        $result['payment_method_title'] = (string) $order->get_payment_method_title();
        $result['shipping_method'] = implode(', ', array_map(function ($method) {
            return $method->get_name();
        }, $order->get_shipping_methods()));
        $result['customer_note'] = (string) $order->get_customer_note();
        $result['billing'] = $order->get_address('billing');
        $result['shipping'] = $order->get_address('shipping');
        $result['notes'] = array();
    }
    return $result;
}

function magna_store_addresses() {
    $user = magna_store_current_user();
    $items = get_user_meta($user->ID, 'magna_store_addresses', true);
    $items = is_array($items) ? array_values($items) : array();
    return array('items' => $items, 'total' => count($items));
}

function magna_store_address_payload($body) {
    $type = sanitize_key($body['address_type'] ?? 'shipping');
    if (!in_array($type, array('shipping', 'billing'), true)) {
        return new WP_Error('magna_invalid_address', 'Invalid address type.', array('status' => 422));
    }
    return array(
        'label' => sanitize_text_field($body['label'] ?? 'Home'),
        'address_type' => $type,
        'first_name' => sanitize_text_field($body['first_name'] ?? ''),
        'last_name' => sanitize_text_field($body['last_name'] ?? ''),
        'company' => sanitize_text_field($body['company'] ?? ''),
        'phone' => sanitize_text_field($body['phone'] ?? ''),
        'address1' => sanitize_text_field($body['address1'] ?? ''),
        'address2' => sanitize_text_field($body['address2'] ?? ''),
        'city' => sanitize_text_field($body['city'] ?? ''),
        'state' => sanitize_text_field($body['state'] ?? ''),
        'postcode' => sanitize_text_field($body['postcode'] ?? ''),
        'country' => strtoupper(sanitize_text_field($body['country'] ?? 'IN')),
        'is_default' => !empty($body['is_default']),
    );
}

function magna_store_save_addresses($user_id, $items) {
    update_user_meta($user_id, 'magna_store_addresses', array_values($items));
}

function magna_store_create_address($request) {
    $user = magna_store_current_user();
    $address = magna_store_address_payload(magna_store_request_body($request));
    if (is_wp_error($address)) return $address;
    $items = get_user_meta($user->ID, 'magna_store_addresses', true);
    $items = is_array($items) ? array_values($items) : array();
    $address['id'] = (int) round(microtime(true) * 1000);
    if ($address['is_default'] || count($items) === 0) {
        foreach ($items as &$item) $item['is_default'] = false;
    }
    $items[] = $address;
    magna_store_save_addresses($user->ID, $items);
    return $address;
}

function magna_store_find_address($items, $id) {
    foreach ($items as $index => $item) {
        if ((int) ($item['id'] ?? 0) === (int) $id) {
            return $index;
        }
    }
    return -1;
}

function magna_store_update_address($request) {
    $user = magna_store_current_user();
    $items = get_user_meta($user->ID, 'magna_store_addresses', true);
    $items = is_array($items) ? array_values($items) : array();
    $index = magna_store_find_address($items, $request['id']);
    if ($index < 0) return new WP_Error('magna_address_not_found', 'Address not found.', array('status' => 404));
    $updated = magna_store_address_payload(array_merge($items[$index], magna_store_request_body($request)));
    if (is_wp_error($updated)) return $updated;
    $updated['id'] = $items[$index]['id'];
    if ($updated['is_default']) {
        foreach ($items as &$item) $item['is_default'] = false;
    }
    $items[$index] = $updated;
    magna_store_save_addresses($user->ID, $items);
    return $updated;
}

function magna_store_delete_address($request) {
    $user = magna_store_current_user();
    $items = get_user_meta($user->ID, 'magna_store_addresses', true);
    $items = is_array($items) ? array_values($items) : array();
    $index = magna_store_find_address($items, $request['id']);
    if ($index < 0) return new WP_Error('magna_address_not_found', 'Address not found.', array('status' => 404));
    array_splice($items, $index, 1);
    magna_store_save_addresses($user->ID, $items);
    return new WP_REST_Response(null, 204);
}

function magna_store_default_address($request) {
    $user = magna_store_current_user();
    $items = get_user_meta($user->ID, 'magna_store_addresses', true);
    $items = is_array($items) ? array_values($items) : array();
    $index = magna_store_find_address($items, $request['id']);
    if ($index < 0) return new WP_Error('magna_address_not_found', 'Address not found.', array('status' => 404));
    foreach ($items as &$item) $item['is_default'] = false;
    $items[$index]['is_default'] = true;
    magna_store_save_addresses($user->ID, $items);
    return $items[$index];
}

function magna_store_register_device($request) {
    $user = magna_store_current_user();
    $body = magna_store_request_body($request);
    $token = sanitize_text_field($body['token'] ?? '');
    if ($token === '') return new WP_Error('magna_invalid_device', 'Device token is required.', array('status' => 422));
    update_user_meta($user->ID, 'magna_fcm_token', $token);
    update_user_meta($user->ID, 'magna_fcm_platform', sanitize_key($body['platform'] ?? 'unknown'));
    update_user_meta($user->ID, 'magna_fcm_enabled', !empty($body['enabled']));
    return array('message' => 'Device registration updated successfully.', 'enabled' => !empty($body['enabled']));
}

function magna_store_razorpay_request($method, $path, $body = null) {
    if (!defined('MAGNA_RAZORPAY_KEY_ID') || !defined('MAGNA_RAZORPAY_KEY_SECRET')) {
        return new WP_Error('magna_payment_config', 'Payment gateway is not configured.', array('status' => 503));
    }
    $args = array(
        'method' => $method,
        'timeout' => 20,
        'headers' => array(
            'Authorization' => 'Basic ' . base64_encode(MAGNA_RAZORPAY_KEY_ID . ':' . MAGNA_RAZORPAY_KEY_SECRET),
            'Content-Type' => 'application/json',
        ),
    );
    if ($body !== null) $args['body'] = wp_json_encode($body);
    $response = wp_remote_request('https://api.razorpay.com/v1/' . ltrim($path, '/'), $args);
    if (is_wp_error($response)) return $response;
    $code = wp_remote_retrieve_response_code($response);
    $data = json_decode(wp_remote_retrieve_body($response), true);
    if ($code < 200 || $code >= 300 || !is_array($data)) {
        return new WP_Error('magna_payment_gateway', 'Payment gateway request failed.', array('status' => 502));
    }
    return $data;
}

/**
 * Send an SMS through Textbee for a WooCommerce order.
 *
 * $event must uniquely identify the notification type:
 * - order_placed
 * - payment_success
 */
function magna_store_send_order_sms($order, $event) {
    if (!$order || !is_a($order, 'WC_Order')) {
        return false;
    }

    if (
        !defined('MAGNA_TEXTBEE_ENABLED') ||
        MAGNA_TEXTBEE_ENABLED !== true ||
        !defined('MAGNA_TEXTBEE_API_KEY') ||
        MAGNA_TEXTBEE_API_KEY === ''
    ) {
        return false;
    }

    $event = sanitize_key($event);

    if (!in_array($event, array('order_placed', 'payment_success'), true)) {
        return false;
    }

    // Prevent repeated notifications for the same order and event.
    $meta_key = '_magna_textbee_' . $event . '_sent';

    if ($order->get_meta($meta_key)) {
        return true;
    }

    $phone = (string) $order->get_billing_phone();

    // Keep only digits and an optional leading plus sign.
    $phone = preg_replace('/[^\d+]/', '', trim($phone));

    // Default to India's country code when the number has 10 digits.
    if (preg_match('/^\d{10}$/', $phone)) {
        $phone = '+91' . $phone;
    } elseif (preg_match('/^91\d{10}$/', $phone)) {
        $phone = '+' . $phone;
    }

    // Reject malformed numbers rather than sending to an invalid recipient.
    if (!preg_match('/^\+[1-9]\d{7,14}$/', $phone)) {
        wc_get_logger()->warning(
            'Textbee SMS skipped: invalid billing phone for order ' . $order->get_id(),
            array('source' => 'magna-textbee')
        );

        return false;
    }

    $order_number = $order->get_order_number();
    $total = html_entity_decode(
        wp_strip_all_tags($order->get_formatted_order_total()),
        ENT_QUOTES,
        get_bloginfo('charset')
    );

    if ($event === 'order_placed') {
        $message = sprintf(
            'Magna Data Store: Your order #%s has been placed. Total: %s. Thank you for shopping with us!',
            $order_number,
            $total
        );
    } else {
        $message = sprintf(
            'Magna Data Store: Payment successful for order #%s. Amount: %s. Thank you for your purchase!',
            $order_number,
            $total
        );
    }

    $response = wp_remote_post(
        'https://api.textbee.dev/api/v1/gateway/send-sms',
        array(
            'timeout' => 15,
            'headers' => array(
                'x-api-key' => MAGNA_TEXTBEE_API_KEY,
                'Content-Type' => 'application/json',
            ),
            'body' => wp_json_encode(array(
                'recipients' => array($phone),
                'message' => $message,
            )),
        )
    );

    if (is_wp_error($response)) {
        wc_get_logger()->warning(
            'Textbee request failed for order ' . $order->get_id() .
            ': ' . $response->get_error_message(),
            array('source' => 'magna-textbee')
        );

        return false;
    }

    $status_code = (int) wp_remote_retrieve_response_code($response);

    if ($status_code < 200 || $status_code >= 300) {
        wc_get_logger()->warning(
            'Textbee returned HTTP ' . $status_code .
            ' for order ' . $order->get_id(),
            array('source' => 'magna-textbee')
        );

        return false;
    }

    // Record success only after Textbee accepts the request.
    $order->update_meta_data($meta_key, current_time('mysql'));
    $order->save();

    return true;
}

function magna_store_create_payment_order($request) {
    $created = magna_store_create_order($request);
    if (is_wp_error($created)) return $created;
    $gateway = magna_store_razorpay_request('POST', 'orders', array(
        'amount' => (int) $created['amount'],
        'currency' => (string) $created['currency'],
        'receipt' => 'wc-' . $created['woocommerce_order_id'],
        'notes' => array('woocommerce_order_id' => (string) $created['woocommerce_order_id']),
    ));
    if (is_wp_error($gateway)) return $gateway;
    update_post_meta((int) $created['woocommerce_order_id'], '_magna_razorpay_order_id', sanitize_text_field($gateway['id'] ?? ''));
    return array_merge($created, array(
        'razorpay_order_id' => sanitize_text_field($gateway['id'] ?? ''),
        'key_id' => defined('MAGNA_RAZORPAY_KEY_ID') ? MAGNA_RAZORPAY_KEY_ID : '',
    ));
}

function magna_store_verify_payment($request) {
    $user = magna_store_current_user();
    $body = magna_store_request_body($request);
    $order_id = sanitize_text_field($body['razorpay_order_id'] ?? '');
    $payment_id = sanitize_text_field($body['razorpay_payment_id'] ?? '');
    $signature = sanitize_text_field($body['razorpay_signature'] ?? '');
    if (!defined('MAGNA_RAZORPAY_KEY_SECRET') || !$order_id || !$payment_id || !$signature) {
        return new WP_Error('magna_invalid_payment', 'Invalid payment verification request.', array('status' => 400));
    }
    $expected = hash_hmac('sha256', $order_id . '|' . $payment_id, MAGNA_RAZORPAY_KEY_SECRET);
    if (!hash_equals($expected, $signature)) {
        return new WP_Error('magna_invalid_signature', 'Invalid payment signature.', array('status' => 400));
    }
    $payments = magna_store_razorpay_request('GET', 'payments/' . rawurlencode($payment_id));
    if (is_wp_error($payments)) return $payments;
    $notes = $payments['notes'] ?? array();
    $wc_id = absint($notes['woocommerce_order_id'] ?? 0);
    $order = $wc_id ? wc_get_order($wc_id) : false;
    if (!$order || (int) $order->get_customer_id() !== (int) $user->ID) {
        return new WP_Error('magna_order_not_found', 'Order not found.', array('status' => 404));
    }
    if ((int) $payments['amount'] !== (int) round((float) $order->get_total() * 100) ||
        (string) ($payments['currency'] ?? '') !== (string) $order->get_currency()) {
        return new WP_Error('magna_payment_mismatch', 'Payment amount or currency does not match the order.', array('status' => 400));
    }
    if (($payments['status'] ?? '') === 'captured') {
    $order->payment_complete($payment_id);
    $order->save();
    magna_store_send_order_sms($order, 'payment_success');
    return array(
        'status' => 'paid',
        'woocommerce_order_id' => $wc_id
    );
}
    return array('status' => sanitize_text_field($payments['status'] ?? 'pending'), 'woocommerce_order_id' => $wc_id);
}

function magna_store_email_invoice($request) {
    $user = magna_store_current_user();
    $order = wc_get_order((int) $request['id']);
    if (!$order || (int) $order->get_customer_id() !== (int) $user->ID) {
        return new WP_Error('magna_order_not_found', 'Order not found.', array('status' => 404));
    }
    if (!class_exists('\Dompdf\Dompdf')) {
        return new WP_Error(
            'magna_invoice_dependency',
            'Install a WordPress PDF renderer before enabling invoice email.',
            array('status' => 503)
        );
    }
    $dompdf = new \Dompdf\Dompdf();
    $dompdf->loadHtml(
        '<h1>Invoice #' . esc_html($order->get_order_number()) . '</h1>' .
        '<p>Total: ' . esc_html($order->get_formatted_order_total()) . '</p>'
    );
    $dompdf->render();
    $path = wp_tempnam('magna-invoice-' . $order->get_id() . '.pdf');
    file_put_contents($path, $dompdf->output());
    $sent = wp_mail(
        $order->get_billing_email(),
        'Invoice #' . $order->get_order_number(),
        'Please find your invoice attached.',
        array('Content-Type: text/plain; charset=UTF-8'),
        array($path)
    );
    wp_delete_file($path);
    if (!$sent) {
        return new WP_Error('magna_invoice_failed', 'Unable to send the invoice.', array('status' => 502));
    }
    return array('status' => 'sent');
}

function magna_store_create_order($request) {
    $user = magna_store_current_user();
    $body = magna_store_request_body($request);
    $items = array();
    foreach ((array) ($body['items'] ?? array()) as $item) {
        $product_id = absint($item['product_id'] ?? 0);
        $quantity = max(1, absint($item['quantity'] ?? 0));
        if (!$product_id || !wc_get_product($product_id)) {
            return new WP_Error('magna_invalid_product', 'One or more products are unavailable.', array('status' => 400));
        }

        $items[] = array('product_id' => $product_id, 'quantity' => $quantity);
    }
    if (!$items) return new WP_Error('magna_empty_cart', 'Your cart is empty.', array('status' => 422));

    $billing = (array) ($body['billing'] ?? array());
    $order = wc_create_order(array('customer_id' => $user->ID));
    if (is_wp_error($order)) return $order;
    foreach ($items as $item) $order->add_product(wc_get_product($item['product_id']), $item['quantity']);
    $order->set_address(array_merge($billing, array('email' => $user->user_email)), 'billing');
    $order->set_address((array) ($body['shipping'] ?? $billing), 'shipping');
    $order->set_payment_method('cod');
    $order->set_payment_method_title('Cash on delivery');
    $order->calculate_totals();
    $order->save();
    return array(
        'woocommerce_order_id' => $order->get_id(),
        'order_number' => $order->get_order_number(),
        'subtotal' => (string) $order->get_subtotal(),
        'shipping_total' => (string) $order->get_shipping_total(),
        'discount_total' => (string) $order->get_discount_total(),
        'total_tax' => (string) $order->get_total_tax(),
        'total' => (string) $order->get_total(),
        'currency' => $order->get_currency(),
        'amount' => (int) round((float) $order->get_total() * 100),
    );
}

function magna_store_phonepe_config() {
    $required = array(
        'MAGNA_PHONEPE_CLIENT_ID',
        'MAGNA_PHONEPE_CLIENT_SECRET',
        'MAGNA_PHONEPE_CLIENT_VERSION',
        'MAGNA_PHONEPE_MERCHANT_ID',
    );
    foreach ($required as $constant) {
        if (!defined($constant) || constant($constant) === '') {
            return new WP_Error('magna_phonepe_config', 'PhonePe is not configured.', array('status' => 503));
        }
    }
    return array(
        'environment' => defined('MAGNA_PHONEPE_ENVIRONMENT') ? MAGNA_PHONEPE_ENVIRONMENT : 'PRODUCTION',
        'client_id' => MAGNA_PHONEPE_CLIENT_ID,
        'client_secret' => MAGNA_PHONEPE_CLIENT_SECRET,
        'client_version' => MAGNA_PHONEPE_CLIENT_VERSION,
        'merchant_id' => MAGNA_PHONEPE_MERCHANT_ID,
    );
}

function magna_store_phonepe_request($method, $path, $body = null, $query = '') {
    $config = magna_store_phonepe_config();
    if (is_wp_error($config)) return $config;
    $sandbox = strtoupper($config['environment']) === 'SANDBOX';
    $base = $sandbox
        ? 'https://api-preprod.phonepe.com/apis/pg-sandbox'
        : 'https://api.phonepe.com/apis/pg';
    $token_url = $sandbox
        ? $base . '/v1/oauth/token'
        : 'https://api.phonepe.com/apis/identity-manager/v1/oauth/token';
    $token_response = wp_remote_post($token_url, array(
        'timeout' => 20,
        'headers' => array('Content-Type' => 'application/x-www-form-urlencoded'),
        'body' => array(
            'client_id' => $config['client_id'],
            'client_version' => $config['client_version'],
            'client_secret' => $config['client_secret'],
            'grant_type' => 'client_credentials',
        ),
    ));
    if (is_wp_error($token_response)) return $token_response;
    $token_data = json_decode(wp_remote_retrieve_body($token_response), true);
    if (wp_remote_retrieve_response_code($token_response) < 200 ||
        wp_remote_retrieve_response_code($token_response) >= 300 ||
        !is_array($token_data) ||
        empty($token_data['access_token'])) {
        return new WP_Error('magna_phonepe_auth', 'PhonePe authorization failed.', array('status' => 502));
    }
    $headers = array(
        'Authorization' => 'O-' . sanitize_text_field($token_data['access_token']),
        'Content-Type' => 'application/json',
        'X-MERCHANT-ID' => $config['merchant_id'],
    );
    $args = array('method' => $method, 'timeout' => 20, 'headers' => $headers);
    if ($body !== null) $args['body'] = wp_json_encode($body);
    $response = wp_remote_request($base . '/' . ltrim($path, '/') . $query, $args);
    if (is_wp_error($response)) return $response;
    $data = json_decode(wp_remote_retrieve_body($response), true);
    $code = wp_remote_retrieve_response_code($response);
    if ($code < 200 || $code >= 300 || !is_array($data)) {
        return new WP_Error('magna_phonepe_gateway', 'PhonePe request failed.', array('status' => 502));
    }
    return $data;
}

function magna_store_create_phonepe_payment($request) {
    $created = magna_store_create_order($request);
    if (is_wp_error($created)) return $created;
    $order = wc_get_order((int) $created['woocommerce_order_id']);
    if (!$order) return new WP_Error('magna_order_not_found', 'Order not found.', array('status' => 404));
    if (strtoupper($order->get_currency()) !== 'INR') {
        return new WP_Error('magna_phonepe_currency', 'PhonePe checkout requires an INR order.', array('status' => 400));
    }
    $order->set_payment_method('phonepe');
    $order->set_payment_method_title('PhonePe');
    $order->update_status('pending');
    $order->save();

    $merchant_order_id = 'MAGNA-' . $order->get_id() . '-' . strtolower(wp_generate_password(10, false, false));
    $payment = magna_store_phonepe_request('POST', 'checkout/v2/sdk/order', array(
        'merchantOrderId' => $merchant_order_id,
        'amount' => (int) $created['amount'],
        'expireAfter' => 1200,
        'paymentFlow' => array(
            'type' => 'PG_CHECKOUT',
        ),
        'metaInfo' => array('udf1' => (string) $order->get_id()),
    ));
    if (is_wp_error($payment)) {
        $order->update_status('failed', 'PhonePe payment initialization failed.');
        return $payment;
    }
    $phonepe_order_id = sanitize_text_field($payment['orderId'] ?? '');
    $phonepe_token = sanitize_text_field($payment['token'] ?? '');
    if ($phonepe_order_id === '' || $phonepe_token === '') {
        return new WP_Error('magna_phonepe_response', 'PhonePe returned incomplete SDK order data.', array('status' => 502));
    }
    $order->update_meta_data('_magna_phonepe_merchant_order_id', $merchant_order_id);
    $order->update_meta_data('_magna_phonepe_amount', (string) $created['amount']);
    $order->save();
    return array_merge($created, array(
        'payment_method' => 'phonepe',
        'phonepe_merchant_order_id' => $merchant_order_id,
        'phonepe_order_id' => $phonepe_order_id,
        'phonepe_token' => $phonepe_token,
        'merchant_id' => MAGNA_PHONEPE_MERCHANT_ID,
    ));
}

function magna_store_apply_phonepe_status($order, $status) {
    $state = strtoupper(sanitize_text_field($status['state'] ?? ''));
    $amount = (int) ($status['amount'] ?? 0);
    $expected_amount = (int) round((float) $order->get_total() * 100);
    if (strtoupper($order->get_currency()) !== 'INR') {
        return new WP_Error('magna_payment_currency', 'PhonePe payment currency does not match the order.', array('status' => 400));
    }
    if ($amount !== $expected_amount) {
        return new WP_Error('magna_payment_mismatch', 'PhonePe amount does not match the order.', array('status' => 400));
    }
    if ($state === 'COMPLETED') {
    $details = (array) ($status['paymentDetails'] ?? array());
    $transaction_id = sanitize_text_field(
        $details[0]['transactionId'] ?? ''
    );
    if (!$order->is_paid()) {
        $order->payment_complete($transaction_id);
    }
    $order->save();
    magna_store_send_order_sms($order, 'payment_success');
    return 'paid';
}
    if ($state === 'FAILED') {
        if (!$order->is_paid()) $order->update_status('failed');
        return 'failed';
    }
    return 'pending';
}


function magna_store_phonepe_status($request) {
    $user = magna_store_current_user();
    $order = wc_get_order((int) $request['id']);
    if (!$order || (int) $order->get_customer_id() !== (int) $user->ID) {
        return new WP_Error('magna_order_not_found', 'Order not found.', array('status' => 404));
    }
    $merchant_order_id = $order->get_meta('_magna_phonepe_merchant_order_id');
    if (!$merchant_order_id) {
        return new WP_Error('magna_phonepe_order_not_found', 'PhonePe payment was not initialized.', array('status' => 404));
    }
    $status = magna_store_phonepe_request(
        'GET',
        'checkout/v2/order/' . rawurlencode($merchant_order_id) . '/status',
        null,
        '?details=true'
    );
    if (is_wp_error($status)) return $status;
    $payment_status = magna_store_apply_phonepe_status($order, $status);
    if (is_wp_error($payment_status)) return $payment_status;
    return array(
        'woocommerce_order_id' => $order->get_id(),
        'payment_status' => $payment_status,
        'order_status' => $order->get_status(),
    );
}

function magna_store_phonepe_webhook($request) {
    if (!defined('MAGNA_PHONEPE_WEBHOOK_SECRET') || MAGNA_PHONEPE_WEBHOOK_SECRET === '') {
        return new WP_Error('magna_phonepe_webhook_config', 'PhonePe webhook is not configured.', array('status' => 503));
    }
    $raw_body = $request->get_body();
    $signature = $request->get_header('x-phonepe-checksum-signature');
    $expected = hash_hmac('sha256', $raw_body, MAGNA_PHONEPE_WEBHOOK_SECRET);
    if (!$signature || !hash_equals($expected, $signature)) {
        return new WP_Error('magna_phonepe_webhook_auth', 'Invalid PhonePe webhook signature.', array('status' => 401));
    }
    $body = json_decode($raw_body, true);
    $payload = (array) ($body['payload'] ?? array());
    $merchant_order_id = sanitize_text_field($payload['merchantOrderId'] ?? '');
    if (!$merchant_order_id) {
        return new WP_Error('magna_phonepe_webhook_payload', 'Invalid PhonePe webhook payload.', array('status' => 400));
    }
    $orders = wc_get_orders(array('limit' => 1, 'meta_key' => '_magna_phonepe_merchant_order_id', 'meta_value' => $merchant_order_id));
    $order = $orders ? $orders[0] : false;
    if (!$order) return new WP_Error('magna_order_not_found', 'Order not found.', array('status' => 404));
    $payment_status = magna_store_apply_phonepe_status($order, $payload);
    if (is_wp_error($payment_status)) return $payment_status;
    return array('received' => true, 'payment_status' => $payment_status);
}
