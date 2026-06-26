<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect("http://localhost:8080/DoorMart/login.html");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Cart - DoorMart</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@tabler/icons-webfont@latest/tabler-icons.min.css">
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: Arial, sans-serif; background: #f5f5f5; }
    nav { background: #C0392B; padding: 14px 24px; display: flex; justify-content: space-between; align-items: center; }
    nav h2 { color: white; font-size: 18px; font-weight: 500; display: flex; align-items: center; gap: 8px; }
    nav a { color: rgba(255,255,255,0.85); text-decoration: none; font-size: 14px; display: flex; align-items: center; gap: 4px; }
    .container { max-width: 600px; margin: 24px auto; padding: 0 20px; }
    h1 { font-size: 20px; font-weight: 500; color: #2c3e50; margin-bottom: 20px; display: flex; align-items: center; gap: 8px; }
    .section { background: white; border: 0.5px solid #e0e0e0; border-radius: 14px; padding: 20px; margin-bottom: 16px; }
    .section h2 { font-size: 15px; font-weight: 500; color: #2c3e50; margin-bottom: 16px; display: flex; align-items: center; gap: 8px; }
    .cart-item { display: flex; justify-content: space-between; align-items: center; padding: 12px 0; border-bottom: 0.5px solid #f0f0f0; }
    .cart-item:last-child { border-bottom: none; }
    .item-info { flex: 1; }
    .item-name { font-size: 14px; font-weight: 500; color: #2c3e50; }
    .item-qty { font-size: 12px; color: #888; margin-top: 2px; }
    .item-price { font-size: 15px; font-weight: 500; color: #C0392B; margin-right: 12px; }
    .remove-btn { background: #FCEBEB; border: none; color: #C0392B; width: 30px; height: 30px; border-radius: 8px; cursor: pointer; display: flex; align-items: center; justify-content: center; }
    .total-row { display: flex; justify-content: space-between; align-items: center; padding-top: 16px; margin-top: 8px; border-top: 0.5px solid #f0f0f0; }
    .total-label { font-size: 15px; color: #555; font-weight: 500; }
    .total-amount { font-size: 20px; font-weight: 500; color: #C0392B; }
    .form-group { margin-bottom: 14px; }
    label { font-size: 13px; color: #555; display: block; margin-bottom: 6px; font-weight: 500; }
    .input-wrap { position: relative; }
    .input-wrap i { position: absolute; left: 12px; top: 50%; transform: translateY(-50%); color: #aaa; font-size: 18px; }
    input { width: 100%; padding: 10px 12px 10px 38px; border: 0.5px solid #ddd; border-radius: 10px; font-size: 14px; color: #333; outline: none; }
    input:focus { border-color: #C0392B; }
    .order-btn { width: 100%; padding: 14px; background: #C0392B; color: white; border: none; border-radius: 12px; font-size: 15px; font-weight: 500; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 8px; }
    .order-btn:hover { background: #A93226; }
    .empty { text-align: center; color: #888; padding: 3rem; }
    .empty i { font-size: 48px; color: #ddd; display: block; margin-bottom: 12px; }
    .success { background: #EAF3DE; color: #3B6D11; padding: 14px; border-radius: 12px; margin-bottom: 16px; font-size: 14px; display: flex; align-items: center; gap: 8px; }
    .cod-badge { background: #EAF3DE; color: #3B6D11; padding: 8px 14px; border-radius: 10px; font-size: 13px; display: flex; align-items: center; gap: 6px; margin-bottom: 16px; }
  </style>
</head>
<body>

  <nav>
    <h2><i class="ti ti-home" aria-hidden="true"></i> DoorMart</h2>
    <a href="http://localhost:8080/DoorMart/customer/shops.jsp"><i class="ti ti-arrow-left" aria-hidden="true"></i> Back to Shops</a>
  </nav>

  <div class="container">
    <h1><i class="ti ti-shopping-cart" aria-hidden="true"></i> Your Cart</h1>

    <div id="success-msg"></div>

    <div class="section" id="cart-section">
      <h2><i class="ti ti-list" aria-hidden="true"></i> Order Items</h2>
      <div id="cart-area"><p class="empty"><i class="ti ti-shopping-cart"></i>Your cart is empty!</p></div>
    </div>

    <div class="section" id="order-section" style="display:none;">
      <h2><i class="ti ti-truck" aria-hidden="true"></i> Delivery Details</h2>
      <div class="cod-badge">
        <i class="ti ti-cash" aria-hidden="true"></i>
        Cash on delivery — pay when you receive!
      </div>
      <div class="form-group">
        <label>Delivery address</label>
        <div class="input-wrap">
          <i class="ti ti-map-pin"></i>
          <input type="text" id="deliveryAddress" placeholder="Your delivery address" />
        </div>
      </div>
      <div class="form-group">
        <label>Phone number</label>
        <div class="input-wrap">
          <i class="ti ti-phone"></i>
          <input type="text" id="deliveryPhone" placeholder="07X XXXXXXX" />
        </div>
      </div>
      <button class="order-btn" onclick="placeOrder()">
        <i class="ti ti-check" aria-hidden="true"></i>
        Place Order
      </button>
    </div>
  </div>

  <script>
    let cart = JSON.parse(localStorage.getItem('cart') || '[]');
    const shopId = localStorage.getItem('shopId');
    window.onload = renderCart;

    function renderCart() {
      const area = document.getElementById('cart-area');
      const orderSection = document.getElementById('order-section');

      if (cart.length === 0) {
        area.innerHTML = '<p class="empty"><i class="ti ti-shopping-cart"></i>Your cart is empty!</p>';
        orderSection.style.display = 'none';
        return;
      }

      let html = '';
      let total = 0;
      for (let i = 0; i < cart.length; i++) {
        let item = cart[i];
        let itemTotal = item.price * item.quantity;
        total += itemTotal;
        html += '<div class="cart-item">';
        html += '<div class="item-info">';
        html += '<p class="item-name">' + item.name + '</p>';
        html += '<p class="item-qty">Qty: ' + item.quantity + '</p>';
        html += '</div>';
        html += '<span class="item-price">Rs. ' + itemTotal + '</span>';
        html += '<button class="remove-btn" onclick="removeItem(' + i + ')"><i class="ti ti-x" aria-hidden="true"></i></button>';
        html += '</div>';
      }

      html += '<div class="total-row"><span class="total-label">Total</span><span class="total-amount">Rs. ' + total + '</span></div>';
      area.innerHTML = html;
      orderSection.style.display = 'block';
    }

    function removeItem(i) {
      cart.splice(i, 1);
      localStorage.setItem('cart', JSON.stringify(cart));
      renderCart();
    }

    function placeOrder() {
      const address = document.getElementById('deliveryAddress').value.trim();
      const phone = document.getElementById('deliveryPhone').value.trim();

      if (!address || !phone) {
        alert('Please fill delivery address and phone!');
        return;
      }

      const total = cart.reduce((sum, item) => sum + (item.price * item.quantity), 0);

      fetch('http://localhost:8080/DoorMart/OrderServlet', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          shopId: shopId,
          deliveryAddress: address,
          deliveryPhone: phone,
          totalAmount: total,
          items: cart
        })
      })
      .then(response => response.json())
      .then(data => {
        if (data.success) {
          localStorage.removeItem('cart');
          localStorage.removeItem('shopId');
          cart = [];
          renderCart();
          document.getElementById('success-msg').innerHTML = '<div class="success"><i class="ti ti-check" aria-hidden="true"></i> Order placed successfully! Shop owner will contact you soon.</div>';
        } else {
          alert('Order failed! Please try again.');
        }
      });
    }
  </script>

</body>
</html>