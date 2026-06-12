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
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: Arial, sans-serif; background: #f5f5f5; }
    nav { background: #e74c3c; padding: 1rem 2rem; display: flex; justify-content: space-between; align-items: center; }
    nav h2 { color: white; font-size: 20px; }
    nav a { color: white; text-decoration: none; font-size: 14px; }
    .container { max-width: 600px; margin: 2rem auto; padding: 0 1rem; }
    h1 { font-size: 24px; color: #2c3e50; margin-bottom: 1.5rem; }
    .section { background: white; border-radius: 12px; padding: 1.5rem; margin-bottom: 1.5rem; box-shadow: 0 2px 8px rgba(0,0,0,0.08); }
    .section h2 { font-size: 18px; color: #2c3e50; margin-bottom: 1rem; }
    table { width: 100%; border-collapse: collapse; font-size: 14px; }
    th { padding: 10px; background: #f5f5f5; text-align: left; border-bottom: 1px solid #ddd; }
    td { padding: 10px; border-bottom: 1px solid #eee; color: #444; }
    .total { font-size: 18px; font-weight: bold; color: #e74c3c; text-align: right; margin-top: 1rem; }
    input { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 8px; font-size: 14px; margin-bottom: 1rem; }
    button { width: 100%; padding: 12px; background: #e74c3c; color: white; border: none; border-radius: 8px; font-size: 16px; cursor: pointer; }
    button:hover { background: #c0392b; }
    .empty { text-align: center; color: #666; padding: 2rem; }
    .remove-btn { background: none; border: none; color: #e74c3c; cursor: pointer; font-size: 14px; width: auto; padding: 0; }
    .success { background: #e8f8e8; color: #27ae60; padding: 1rem; border-radius: 8px; text-align: center; margin-bottom: 1rem; }
  </style>
</head>
<body>

  <nav>
    <h2>🚪 DoorMart</h2>
    <a href="http://localhost:8080/DoorMart/customer/shops.jsp">← Back to Shops</a>
  </nav>

  <div class="container">
    <h1>🛒 Your Cart</h1>

    <div id="success-msg"></div>

    <div class="section">
      <h2>Order Items</h2>
      <div id="cart-area"><p class="empty">Your cart is empty!</p></div>
      <div class="total" id="total"></div>
    </div>

    <div class="section" id="order-section" style="display:none;">
      <h2>Delivery Details</h2>
      <input type="text" id="deliveryAddress" placeholder="Your delivery address" />
      <input type="text" id="deliveryPhone" placeholder="Your phone number" />
      <button onclick="placeOrder()">Place Order 🎉</button>
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
        area.innerHTML = '<p class="empty">Your cart is empty!</p>';
        document.getElementById('total').textContent = '';
        orderSection.style.display = 'none';
        return;
      }

      let rows = '';
      for (let i = 0; i < cart.length; i++) {
        let item = cart[i];
        rows += '<tr>';
        rows += '<td>' + item.name + '</td>';
        rows += '<td>' + item.quantity + '</td>';
        rows += '<td>Rs. ' + (item.price * item.quantity) + '</td>';
        rows += '<td><button class="remove-btn" onclick="removeItem(' + i + ')">❌</button></td>';
        rows += '</tr>';
      }

      area.innerHTML = '<table><thead><tr><th>Product</th><th>Qty</th><th>Price</th><th></th></tr></thead><tbody>' + rows + '</tbody></table>';

      const total = cart.reduce((sum, item) => sum + (item.price * item.quantity), 0);
      document.getElementById('total').textContent = 'Total: Rs. ' + total;
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
          document.getElementById('success-msg').innerHTML = '<div class="success">🎉 Order placed successfully! Shop owner will contact you soon.</div>';
        } else {
          alert('Order failed! Please try again.');
        }
      });
    }
  </script>

</body>
</html>
