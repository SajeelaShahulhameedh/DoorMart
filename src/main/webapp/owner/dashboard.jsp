<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    String userName = (String) session.getAttribute("userName");
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
  <title>Dashboard - DoorMart</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@tabler/icons-webfont@latest/tabler-icons.min.css">
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: Arial, sans-serif; background: #f5f5f5; }
    nav { background: #C0392B; padding: 14px 24px; display: flex; justify-content: space-between; align-items: center; }
    nav h2 { color: white; font-size: 18px; font-weight: 500; display: flex; align-items: center; gap: 8px; }
    nav div { display: flex; gap: 16px; align-items: center; }
    nav a { color: rgba(255,255,255,0.85); text-decoration: none; font-size: 14px; display: flex; align-items: center; gap: 4px; }
    .hero { background: #C0392B; padding: 20px 24px 32px; color: white; }
    .hero h1 { font-size: 20px; font-weight: 500; }
    .hero p { font-size: 14px; opacity: 0.85; margin-top: 4px; }
    .container { padding: 20px; margin-top: -12px; }
    .stats-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px; margin-bottom: 20px; }
    .stat-card { background: white; border: 0.5px solid #e0e0e0; border-radius: 14px; padding: 16px; text-align: center; }
    .stat-card i { font-size: 24px; color: #C0392B; display: block; margin-bottom: 8px; }
    .stat-number { font-size: 24px; font-weight: 500; color: #2c3e50; }
    .stat-label { font-size: 12px; color: #888; margin-top: 4px; }
    .section { background: white; border: 0.5px solid #e0e0e0; border-radius: 14px; padding: 20px; margin-bottom: 16px; }
    .section-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; }
    .section h2 { font-size: 15px; font-weight: 500; color: #2c3e50; display: flex; align-items: center; gap: 8px; }
    .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
    .form-group { margin-bottom: 14px; }
    label { font-size: 13px; color: #555; display: block; margin-bottom: 6px; font-weight: 500; }
    .input-wrap { position: relative; }
    .input-wrap i { position: absolute; left: 12px; top: 50%; transform: translateY(-50%); color: #aaa; font-size: 18px; }
    input, textarea { width: 100%; padding: 10px 12px 10px 38px; border: 0.5px solid #ddd; border-radius: 10px; font-size: 14px; color: #333; outline: none; }
    input:focus, textarea:focus { border-color: #C0392B; }
    textarea { padding-left: 38px; resize: none; }
    .btn { padding: 10px 20px; background: #C0392B; color: white; border: none; border-radius: 10px; font-size: 14px; font-weight: 500; cursor: pointer; display: flex; align-items: center; gap: 6px; }
    .btn:hover { background: #A93226; }
    .btn-small { padding: 6px 12px; font-size: 12px; border-radius: 8px; }
    table { width: 100%; border-collapse: collapse; font-size: 14px; }
    th { padding: 10px 12px; background: #f9f9f9; text-align: left; border-bottom: 0.5px solid #eee; color: #555; font-size: 13px; font-weight: 500; }
    td { padding: 10px 12px; border-bottom: 0.5px solid #f5f5f5; color: #444; }
    .badge { padding: 4px 10px; border-radius: 20px; font-size: 11px; font-weight: 500; }
    .badge-green { background: #EAF3DE; color: #3B6D11; }
    .badge-red { background: #FCEBEB; color: #A32D2D; }
    .empty { text-align: center; color: #888; padding: 2rem; font-size: 14px; }
  </style>
</head>
<body>

  <nav>
    <h2><i class="ti ti-home" aria-hidden="true"></i> DoorMart</h2>
    <div>
      <a href="http://localhost:8080/DoorMart/owner/setup.jsp"><i class="ti ti-settings" aria-hidden="true"></i> Shop</a>
      <a href="http://localhost:8080/DoorMart/owner/orders.jsp"><i class="ti ti-clipboard-list" aria-hidden="true"></i> Orders</a>
      <a href="http://localhost:8080/DoorMart/login.html"><i class="ti ti-logout" aria-hidden="true"></i> Logout</a>
    </div>
  </nav>

  <div class="hero">
    <h1>Welcome, <%= userName %>!</h1>
    <p>Manage your shop, products and orders</p>
  </div>

  <div class="container">

    <div class="stats-grid">
      <div class="stat-card">
        <i class="ti ti-package" aria-hidden="true"></i>
        <p class="stat-number" id="totalProducts">0</p>
        <p class="stat-label">Products</p>
      </div>
      <div class="stat-card">
        <i class="ti ti-shopping-cart" aria-hidden="true"></i>
        <p class="stat-number" id="totalOrders">0</p>
        <p class="stat-label">Total Orders</p>
      </div>
      <div class="stat-card">
        <i class="ti ti-clock" aria-hidden="true"></i>
        <p class="stat-number" id="pendingOrders">0</p>
        <p class="stat-label">Pending</p>
      </div>
    </div>

    <div class="section">
      <div class="section-header">
        <h2><i class="ti ti-plus" aria-hidden="true"></i> Add New Product</h2>
      </div>
      <form action="http://localhost:8080/DoorMart/ProductServlet" method="POST">
        <div class="form-row">
          <div class="form-group">
            <label>Product name</label>
            <div class="input-wrap">
              <i class="ti ti-package"></i>
              <input type="text" name="name" placeholder="Product name" required />
            </div>
          </div>
          <div class="form-group">
            <label>Price (Rs.)</label>
            <div class="input-wrap">
              <i class="ti ti-currency-rupee"></i>
              <input type="number" name="price" placeholder="0.00" required />
            </div>
          </div>
        </div>
        <div class="form-group">
          <label>Description</label>
          <div class="input-wrap">
            <i class="ti ti-notes"></i>
            <textarea name="description" placeholder="Product description" rows="2"></textarea>
          </div>
        </div>
        <button class="btn" type="submit">
          <i class="ti ti-plus" aria-hidden="true"></i> Add Product
        </button>
      </form>
    </div>

    <div class="section">
      <h2><i class="ti ti-list" aria-hidden="true"></i> My Products</h2>
      <div id="products-area"><p class="empty">Loading products...</p></div>
    </div>

  </div>

  <script>
    window.onload = loadProducts;

    function loadProducts() {
      fetch('http://localhost:8080/DoorMart/ProductServlet')
        .then(response => response.json())
        .then(products => {
          document.getElementById('totalProducts').textContent = products.length;
          const area = document.getElementById('products-area');
          if (products.length === 0) {
            area.innerHTML = '<p class="empty">No products added yet.</p>';
            return;
          }
          let rows = '';
          for (let i = 0; i < products.length; i++) {
            let p = products[i];
            let available = p.isAvailable == 1;
            rows += '<tr>';
            rows += '<td>' + p.name + '</td>';
            rows += '<td>' + p.description + '</td>';
            rows += '<td>Rs. ' + p.price + '</td>';
            rows += '<td><span class="badge ' + (available ? 'badge-green' : 'badge-red') + '">' + (available ? 'Available' : 'Sold Out') + '</span></td>';
            rows += '<td><form action="http://localhost:8080/DoorMart/ProductServlet" method="POST" style="display:inline">';
            rows += '<input type="hidden" name="action" value="toggle" />';
            rows += '<input type="hidden" name="productId" value="' + p.id + '" />';
            rows += '<button class="btn btn-small" type="submit">' + (available ? 'Mark Sold' : 'Mark Available') + '</button>';
            rows += '</form></td>';
            rows += '</tr>';
          }
          area.innerHTML = '<table><thead><tr><th>Name</th><th>Description</th><th>Price</th><th>Status</th><th></th></tr></thead><tbody>' + rows + '</tbody></table>';
        });

      fetch('http://localhost:8080/DoorMart/OrderServlet')
        .then(response => response.json())
        .then(orders => {
          document.getElementById('totalOrders').textContent = orders.length;
          document.getElementById('pendingOrders').textContent = orders.filter(o => o.status === 'pending').length;
        });
    }
  </script>

</body>
</html>