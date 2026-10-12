<?php
/**
 * Plugin Name: Magna Orders API
 * Description: Read-only, authenticated order history endpoints for the Magna Data Store app.
 * Version: 1.0.0
 */

if (!defined('ABSPATH')) {
    exit;
}

add_action('rest_api_init', 'magna_orders_register_routes');

function magna_orders_register_routes() {
    register_rest_route('magna/v1', '/orders', array(
        'methods'             => WP_REST_Server::READABLE,
        'callback'            => 'magna_orders_list',
        'permission_callback' => 'magna_orders_permission',
        'args'                => array(
            'page'     => array('type' => 'integer', 'default' => 1, 'minimum' => 1),
            'per_page' => array('type' => 'integer', 'default' => 10, 'minimum' => 1, 'maximum' => 50),
            'status'   => array('type' => 'string', 'default' => ''),
        ),
    ));

    register_rest_route('magna/v1', '/orders/(?P<id>\d+)', array(
        'methods'             => WP_REST_Server::READABLE,
        'callback'            => 'magna_orders_get',
        'permission_callback' => 'magna_orders_permission',
    ));
}

function magna_orders_permission() {
    return is_user_logged_in() && function_exists('wc_get_orders');
}

function magna_orders_list(WP_REST_Request $request) {
    $page     = max(1, (int) $request->get_param('page'));
    $per_page = min(50, max(1, (int) $request->get_param('per_page')));
    $status   = sanitize_key((string) $request->get_param('status'));

    $args = array(
        'customer_id' => get_current_user_id(),
        'limit'       => $per_page,
        'paged'       => $page,
        'orderby'     => 'date',
        'order'       => 'DESC',
        'paginate'    => true,
    );

    if ($status !== '' && array_key_exists('wc-' . $status, wc_get_order_statuses())) {
        $args['status'] = array('wc-' . $status);
    }

    $results = wc_get_orders($args);
    $orders  = array();

    foreach ($results->orders as $order) {
        if ($order instanceof WC_Order) {
            $orders[] = magna_orders_format($order, false);
        }
    }

    $response = rest_ensure_response($orders);
    $response->header('X-WP-Total', (int) $results->total);
    $response->header('X-WP-TotalPages', (int) $results->max_num_pages);
    $response->header('Cache-Control', 'no-store');

    return $response;
}

function magna_orders_get(WP_REST_Request $request) {
    $order = wc_get_order((int) $request['id']);

    if (!$order instanceof WC_Order || (int) $order->get_customer_id() !== get_current_user_id()) {
        return new WP_Error('magna_order_not_found', 'Order not found.', array('status' => 404));
    }

    $response = rest_ensure_response(magna_orders_format($order, true));
    $response->header('Cache-Control', 'no-store');

    return $response;
}

function magna_orders_format(WC_Order $order, $detail) {
    $created = $order->get_date_created();

    $data = array(
        'id'           => $order->get_id(),
        'number'       => (string) $order->get_order_number(),
        'status'       => $order->get_status(),
        'status_label' => wc_get_order_status_name($order->get_status()),
        'date_created' => $created ? $created->date('c') : '',
        'currency'     => magna_orders_currency($order),
        'total'        => magna_orders_minor($order->get_total()),
        'item_count'   => (int) $order->get_item_count(),
        'items'        => magna_orders_items($order),
        'tracking'     => magna_orders_tracking($order),
    );

    if ($detail) {
        $shipping_names = array();
        foreach ($order->get_shipping_methods() as $method) {
            $shipping_names[] = $method->get_name();
        }

        $data['subtotal']             = magna_orders_minor($order->get_subtotal());
        $data['discount_total']       = magna_orders_minor($order->get_discount_total());
        $data['shipping_total']       = magna_orders_minor($order->get_shipping_total());
        $data['tax_total']            = magna_orders_minor($order->get_total_tax());
        $data['payment_method_title'] = (string) $order->get_payment_method_title();
        $data['shipping_method']      = implode(', ', $shipping_names);
        $data['customer_note']        = (string) $order->get_customer_note();
        $data['billing']              = magna_orders_address($order->get_address('billing'));
        $data['shipping']             = magna_orders_address($order->get_address('shipping'));
        $data['notes']                = magna_orders_notes($order);
    }

    return $data;
}

function magna_orders_currency(WC_Order $order) {
    $code     = $order->get_currency();
    $symbol   = html_entity_decode(get_woocommerce_currency_symbol($code), ENT_QUOTES, 'UTF-8');
    $position = get_option('woocommerce_currency_pos', 'left');
    $prefix   = '';
    $suffix   = '';

    switch ($position) {
        case 'right':
            $suffix = $symbol;
            break;
        case 'left_space':
            $prefix = $symbol . ' ';
            break;
        case 'right_space':
            $suffix = ' ' . $symbol;
            break;
        default:
            $prefix = $symbol;
    }

    return array(
        'currency_code'               => $code,
        'currency_symbol'             => $symbol,
        'currency_minor_unit'         => wc_get_price_decimals(),
        'currency_decimal_separator'  => wc_get_price_decimal_separator(),
        'currency_thousand_separator' => wc_get_price_thousand_separator(),
        'currency_prefix'             => $prefix,
        'currency_suffix'             => $suffix,
    );
}

function magna_orders_minor($amount) {
    return (string) (int) round((float) $amount * pow(10, wc_get_price_decimals()));
}

function magna_orders_items(WC_Order $order) {
    $items = array();

    foreach ($order->get_items() as $item) {
        if (!$item instanceof WC_Order_Item_Product) {
            continue;
        }

        $product  = $item->get_product();
        $image_id = $product ? $product->get_image_id() : 0;
        $image    = $image_id ? wp_get_attachment_image_url($image_id, 'woocommerce_thumbnail') : '';

        $items[] = array(
            'id'           => $item->get_id(),
            'product_id'   => $item->get_product_id(),
            'variation_id' => $item->get_variation_id(),
            'name'         => $item->get_name(),
            'quantity'     => (int) $item->get_quantity(),
            'subtotal'     => magna_orders_minor($item->get_subtotal()),
            'total'        => magna_orders_minor($item->get_total()),
            'sku'          => $product ? (string) $product->get_sku() : '',
            'image'        => $image ? $image : '',
        );
    }

    return $items;
}

function magna_orders_address($address) {
    $keys = array('first_name', 'last_name', 'company', 'address_1', 'address_2', 'city', 'state', 'postcode', 'country', 'email', 'phone');
    $out  = array();

    foreach ($keys as $key) {
        $out[$key] = isset($address[$key]) ? (string) $address[$key] : '';
    }

    return $out;
}

function magna_orders_tracking(WC_Order $order) {
    $stored = $order->get_meta('_wc_shipment_tracking_items', true);
    $result = array();

    if (!is_array($stored)) {
        return $result;
    }

    foreach ($stored as $item) {
        if (!is_array($item)) {
            continue;
        }

        $provider = !empty($item['custom_tracking_provider'])
            ? $item['custom_tracking_provider']
            : (isset($item['tracking_provider']) ? $item['tracking_provider'] : '');
        $link = !empty($item['custom_tracking_link']) ? $item['custom_tracking_link'] : '';

        if (class_exists('WC_Shipment_Tracking_Actions')) {
            $actions = WC_Shipment_Tracking_Actions::get_instance();

            if (method_exists($actions, 'get_formatted_tracking_item')) {
                $formatted = $actions->get_formatted_tracking_item($order->get_id(), $item);

                if (is_array($formatted)) {
                    if (!empty($formatted['formatted_tracking_provider'])) {
                        $provider = $formatted['formatted_tracking_provider'];
                    }
                    if ($link === '' && !empty($formatted['formatted_tracking_link'])) {
                        $link = $formatted['formatted_tracking_link'];
                    }
                }
            }
        }

        $result[] = array(
            'provider'     => sanitize_text_field((string) $provider),
            'number'       => sanitize_text_field(isset($item['tracking_number']) ? (string) $item['tracking_number'] : ''),
            'link'         => esc_url_raw((string) $link),
            'date_shipped' => !empty($item['date_shipped']) ? gmdate('c', (int) $item['date_shipped']) : '',
        );
    }

    return $result;
}

function magna_orders_notes(WC_Order $order) {
    $notes  = wc_get_order_notes(array('order_id' => $order->get_id(), 'type' => 'customer'));
    $result = array();

    foreach ($notes as $note) {
        $result[] = array(
            'id'   => (int) $note->id,
            'note' => wp_strip_all_tags((string) $note->content),
            'date' => $note->date_created ? $note->date_created->date('c') : '',
        );
    }

    return $result;
}