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
  <title>Orders - DoorMart</title>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: Arial, sans-serif; background: #f5f5f5; }
    nav { background: #e74c3c; padding: 1rem 2rem; display: flex; justify-content: space-between; align-items: center; }
    nav h2 { color: white; font-size: 20px; }
    nav div { display: flex; gap: 20px; }
    nav a { color: white; text-decoration: none; font-size: 14px; }
    .container { max-width: 900px; margin: 2rem auto; padding: 0 1rem; }
    h1 { font-size: 24px; color: #2c3e50; margin-bottom: 1.5rem; }
    .section { background: white; border-radius: 12px; padding: 1.5rem; margin-bottom: 1.5rem; box-shadow: 0 2px 8px rgba(0,0,0,0.08); }
    table { width: 100%; border-collapse: collapse; font-size: 14px; }
    th { padding: 10px; background: #f5f5f5; text-align: left; border-bottom: 1px solid #ddd; color: #2c3e50; }
    td { padding: 10px; border-bottom: 1px solid #eee; color: #444; }
    .badge { padding: 4px 10px; border-radius: 20px; font-size: 12px; }
    .badge-pending { background: #fef5e8; color: #e67e22; }
    .badge-confirmed { background: #e8f0fe; color: #3498db; }
    .badge-delivered { background: #e8f8e8; color: #27ae60; }
    .badge-cancelled { background: #fde8e8; color: #e74c3c; }
    select { padding: 6px 10px; border: 1px solid #ddd; border-radius: 6px; font-size: 13px; }
    .empty { text-align: center; color: #666; padding: 2rem; }
  </style>
</head>
<body>

  <nav>
    <h2>🚪 DoorMart</h2>
    <div>
      <a href="http://localhost:8080/DoorMart/owner/dashboard.jsp">Dashboard</a>
      <a href="http://localhost:8080/DoorMart/login.html">Logout</a>
    </div>
  </nav>

  <div class="container">
    <h1>📋 Incoming Orders</h1>

    <div class="section">
      <div id="orders-area"><p class="empty">Loading orders...</p></div>
    </div>
  </div>

  <script>
    window.onload = loadOrders;

    function loadOrders() {
      fetch('http://localhost:8080/DoorMart/OrderServlet')
        .then(response => response.json())
        .then(orders => {
          const area = document.getElementById('orders-area');
          if (orders.length === 0) {
            area.innerHTML = '<p class="empty">No orders yet!</p>';
            return;
          }
          let rows = '';
          for (let i = 0; i < orders.length; i++) {
            let o = orders[i];
            let badgeClass = 'badge-' + o.status;
            rows += '<tr>';
            rows += '<td>#' + o.id + '</td>';
            rows += '<td>' + o.customerName + '</td>';
            rows += '<td>Rs. ' + o.totalAmount + '</td>';
            rows += '<td>' + o.deliveryAddress + '</td>';
            rows += '<td><span class="badge ' + badgeClass + '">' + o.status + '</span></td>';
            rows += '<td>';
            rows += '<select onchange="updateStatus(' + o.id + ', this.value)">';
            rows += '<option value="pending"' + (o.status == 'pending' ? ' selected' : '') + '>Pending</option>';
            rows += '<option value="confirmed"' + (o.status == 'confirmed' ? ' selected' : '') + '>Confirmed</option>';
            rows += '<option value="delivered"' + (o.status == 'delivered' ? ' selected' : '') + '>Delivered</option>';
            rows += '<option value="cancelled"' + (o.status == 'cancelled' ? ' selected' : '') + '>Cancelled</option>';
            rows += '</select>';
            rows += '</td>';
            rows += '</tr>';
          }
          area.innerHTML = '<table><thead><tr><th>Order ID</th><th>Customer</th><th>Total</th><th>Address</th><th>Status</th><th>Update</th></tr></thead><tbody>' + rows + '</tbody></table>';
        });
    }

    function updateStatus(orderId, status) {
      fetch('http://localhost:8080/DoorMart/OrderServlet', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'updateStatus',
          orderId: orderId,
          status: status
        })
      })
      .then(response => response.json())
      .then(data => {
        if (data.success) {
          loadOrders();
        }
      });
    }
  </script>

</body>
</html>