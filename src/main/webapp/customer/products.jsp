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
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@tabler/icons-webfont@latest/tabler-icons.min.css">
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: Arial, sans-serif; background: #f5f5f5; }
    nav { background: #C0392B; padding: 14px 24px; display: flex; justify-content: space-between; align-items: center; }
    nav h2 { color: white; font-size: 18px; font-weight: 500; display: flex; align-items: center; gap: 8px; }
    nav div { display: flex; gap: 16px; align-items: center; }
    nav a { color: rgba(255,255,255,0.85); text-decoration: none; font-size: 14px; display: flex; align-items: center; gap: 4px; }
    .cart-badge { background: white; color: #C0392B; padding: 4px 12px; border-radius: 20px; font-size: 13px; font-weight: 500; display: flex; align-items: center; gap: 4px; }
    .hero { background: #C0392B; padding: 16px 24px 28px; color: white; }
    .hero h1 { font-size: 18px; font-weight: 500; }
    .hero p { font-size: 13px; opacity: 0.85; margin-top: 4px; }
    .container { padding: 20px; margin-top: -10px; }
    .product-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(180px, 1fr)); gap: 12px; }
    .product-card { background: white; border: 0.5px solid #e0e0e0; border-radius: 14px; padding: 14px; }
    .available-badge { font-size: 11px; background: #EAF3DE; color: #3B6D11; padding: 3px 10px; border-radius: 20px; display: inline-block; margin-bottom: 10px; font-weight: 500; }
    .sold-badge { font-size: 11px; background: #FCEBEB; color: #A32D2D; padding: 3px 10px; border-radius: 20px; display: inline-block; margin-bottom: 10px; font-weight: 500; }
    .product-name { font-size: 14px; font-weight: 500; color: #2c3e50; margin-bottom: 4px; }
    .product-desc { font-size: 12px; color: #888; margin-bottom: 12px; line-height: 1.4; }
    .product-footer { display: flex; justify-content: space-between; align-items: center; }
    .product-price { font-size: 16px; font-weight: 500; color: #C0392B; }
    .add-btn { background: #C0392B; color: white; border: none; padding: 7px 14px; border-radius: 8px; font-size: 13px; cursor: pointer; display: flex; align-items: center; gap: 4px; }
    .add-btn:hover { background: #A93226; }
    .sold-btn { background: #f0f0f0; color: #aaa; border: none; padding: 7px 14px; border-radius: 8px; font-size: 13px; cursor: not-allowed; }
    .go-cart-btn { display: flex; align-items: center; justify-content: center; gap: 8px; width: 100%; padding: 14px; background: #C0392B; color: white; border: none; border-radius: 12px; font-size: 15px; font-weight: 500; cursor: pointer; margin-top: 20px; }
    .go-cart-btn:hover { background: #A93226; }
    .empty { text-align: center; color: #888; padding: 3rem; }
    .empty i { font-size: 48px; color: #ddd; display: block; margin-bottom: 12px; }
  </style>
</head>
<body>

  <nav>
    <h2><i class="ti ti-home" aria-hidden="true"></i> DoorMart</h2>
    <div>
      <span class="cart-badge"><i class="ti ti-shopping-cart" aria-hidden="true"></i> <span id="cartCount">0</span></span>
      <a href="http://localhost:8080/DoorMart/customer/shops.jsp"><i class="ti ti-arrow-left" aria-hidden="true"></i> Back</a>
    </div>
  </nav>

  <div class="hero">
    <h1 id="shopName">Loading...</h1>
    <p>Browse products and add to cart</p>
  </div>

  <div class="container">
    <div class="product-grid" id="products-area">
      <p class="empty"><i class="ti ti-package" aria-hidden="true"></i>Loading products...</p>
    </div>
    <button class="go-cart-btn" onclick="goToCart()">
      <i class="ti ti-shopping-cart" aria-hidden="true"></i>
      Go to Cart (<span id="cartCount2">0</span> items)
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
          document.getElementById('shopName').textContent = data.shopName;
          const area = document.getElementById('products-area');
          if (data.products.length === 0) {
            area.innerHTML = '<p class="empty"><i class="ti ti-package"></i>No products available.</p>';
            return;
          }
          let html = '';
          for (let i = 0; i < data.products.length; i++) {
            let p = data.products[i];
            let available = p.isAvailable == 1;
            html += '<div class="product-card">';
            html += '<span class="' + (available ? 'available-badge' : 'sold-badge') + '">' + (available ? 'Available' : 'Sold Out') + '</span>';
            html += '<p class="product-name">' + p.name + '</p>';
            html += '<p class="product-desc">' + p.description + '</p>';
            html += '<div class="product-footer">';
            html += '<span class="product-price">Rs. ' + p.price + '</span>';
            if (available) {
              html += '<button class="add-btn" onclick="addToCart(' + p.id + ', \'' + p.name + '\', ' + p.price + ')"><i class="ti ti-plus" aria-hidden="true"></i> Add</button>';
            } else {
              html += '<button class="sold-btn">Sold Out</button>';
            }
            html += '</div></div>';
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