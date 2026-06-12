<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    String userName = (String) session.getAttribute("userName");
    if (userId == null) {
        response.sendRedirect("http://localhost:8080/DoorMart/login.html");
        return;
    }
    String shopId = request.getParameter("shopId");
    if (shopId == null) {
        response.sendRedirect("http://localhost:8080/DoorMart/customer/shops.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Products - DoorMart</title>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: Arial, sans-serif; background: #f5f5f5; }
    nav { background: #e74c3c; padding: 1rem 2rem; display: flex; justify-content: space-between; align-items: center; }
    nav h2 { color: white; font-size: 20px; }
    nav div { display: flex; gap: 20px; }
    nav a { color: white; text-decoration: none; font-size: 14px; }
    .container { max-width: 900px; margin: 2rem auto; padding: 0 1rem; }
    h1 { font-size: 24px; color: #2c3e50; margin-bottom: 0.5rem; }
    p { color: #666; margin-bottom: 1.5rem; }
    .product-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 1rem; }
    .product-card { background: white; border-radius: 12px; padding: 1.5rem; box-shadow: 0 2px 8px rgba(0,0,0,0.08); }
    .product-card h3 { font-size: 16px; color: #2c3e50; margin-bottom: 0.5rem; }
    .product-card p { font-size: 13px; color: #666; margin-bottom: 0.5rem; }
    .product-card .price { font-size: 18px; color: #e74c3c; font-weight: bold; margin-bottom: 1rem; }
    .badge { padding: 4px 10px; border-radius: 20px; font-size: 12px; display: inline-block; margin-bottom: 0.5rem; }
    .badge-green { background: #e8f8e8; color: #27ae60; }
    .badge-red { background: #fde8e8; color: #e74c3c; }
    button { width: 100%; padding: 10px; background: #e74c3c; color: white; border: none; border-radius: 8px; font-size: 14px; cursor: pointer; }
    button:hover { background: #c0392b; }
    button:disabled { background: #ddd; cursor: not-allowed; }
    .empty { text-align: center; color: #666; padding: 3rem; }
    .cart-count { background: white; color: #e74c3c; border-radius: 20px; padding: 4px 12px; font-size: 14px; font-weight: bold; }
  </style>
</head>
<body>

  <nav>
    <h2>🚪 DoorMart</h2>
    <div>
      <span class="cart-count">🛒 <span id="cartCount">0</span> items</span>
      <a href="/DoorMart/customer/shops.jsp">← Back</a>
      <a href="/DoorMart/login.html">Logout</a>
    </div>
  </nav>

  <div class="container">
    <h1 id="shopName">Loading...</h1>
    <p>Browse products and add to cart!</p>

    <div class="product-grid" id="products-area">
      <p class="empty">Loading products...</p>
    </div>

    <br/>
    <button onclick="goToCart()" style="max-width: 300px;">
      🛒 Go to Cart (<span id="cartCount2">0</span> items)
    </button>
  </div>

  <script>
    const shopId = '<%=shopId%>';
    let cart = JSON.parse(localStorage.getItem('cart') || '[]');
    updateCartCount();

    window.onload = loadProducts;

    function loadProducts() {
      fetch('http://localhost:8080/DoorMart/ProductServlet?shopId=' + shopId)
        .then(response => response.json())
        .then(data => {
          document.getElementById('shopName').textContent = '🏪 ' + data.shopName;
          const area = document.getElementById('products-area');
          if (data.products.length === 0) {
            area.innerHTML = '<p class="empty">No products available.</p>';
            return;
          }
          let html = '';
          for (let i = 0; i < data.products.length; i++) {
            let p = data.products[i];
            let available = p.isAvailable == 1;
            html += '<div class="product-card">';
            html += '<span class="badge ' + (available ? 'badge-green' : 'badge-red') + '">' + (available ? '✅ Available' : '❌ Sold Out') + '</span>';
            html += '<h3>' + p.name + '</h3>';
            html += '<p>' + p.description + '</p>';
            html += '<p class="price">Rs. ' + p.price + '</p>';
            if (available) {
              html += '<button onclick="addToCart(' + p.id + ', \'' + p.name + '\', ' + p.price + ')">Add to Cart</button>';
            } else {
              html += '<button disabled>Sold Out</button>';
            }
            html += '</div>';
          }
          area.innerHTML = html;
        });
    }

    function addToCart(id, name, price) {
      const existing = cart.find(c => c.id === id);
      if (existing) {
        existing.quantity++;
      } else {
        cart.push({ id, name, price, quantity: 1 });
      }
      localStorage.setItem('cart', JSON.stringify(cart));
      localStorage.setItem('shopId', shopId);
      updateCartCount();
      alert(name + ' added to cart!');
    }

    function updateCartCount() {
      const total = cart.reduce((sum, c) => sum + c.quantity, 0);
      document.getElementById('cartCount').textContent = total;
      document.getElementById('cartCount2').textContent = total;
    }

    function goToCart() {
      window.location = 'http://localhost:8080/DoorMart/customer/cart.jsp';
    }
  </script>

</body>
</html>