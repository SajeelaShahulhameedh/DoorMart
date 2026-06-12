package com.doormart.doormart;

import java.io.*;
import java.sql.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import org.json.JSONArray;
import org.json.JSONObject;

@WebServlet("/OrderServlet")
public class OrderServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");

        if (userId == null) {
            response.setContentType("application/json");
            response.getWriter().print("{\"success\":false}");
            return;
        }

        // Read JSON body
        StringBuilder sb = new StringBuilder();
        BufferedReader reader = request.getReader();
        String line;
        while ((line = reader.readLine()) != null) {
            sb.append(line);
        }

        try {
            JSONObject json = new JSONObject(sb.toString());
            int shopId = json.getInt("shopId");
            String deliveryAddress = json.getString("deliveryAddress");
            double totalAmount = json.getDouble("totalAmount");
            JSONArray items = json.getJSONArray("items");

            Connection conn = DBConnection.getConnection();

            // Insert order
            String orderSql = "INSERT INTO orders (customer_id, shop_id, total_amount, delivery_address) VALUES (?, ?, ?, ?)";
            PreparedStatement orderPs = conn.prepareStatement(orderSql, Statement.RETURN_GENERATED_KEYS);
            orderPs.setInt(1, userId);
            orderPs.setInt(2, shopId);
            orderPs.setDouble(3, totalAmount);
            orderPs.setString(4, deliveryAddress);
            orderPs.executeUpdate();

            // Get generated order id
            ResultSet generatedKeys = orderPs.getGeneratedKeys();
            int orderId = 0;
            if (generatedKeys.next()) {
                orderId = generatedKeys.getInt(1);
            }

            // Insert order items
            for (int i = 0; i < items.length(); i++) {
                JSONObject item = items.getJSONObject(i);
                String itemSql = "INSERT INTO order_items (order_id, product_id, quantity, price) VALUES (?, ?, ?, ?)";
                PreparedStatement itemPs = conn.prepareStatement(itemSql);
                itemPs.setInt(1, orderId);
                itemPs.setInt(2, item.getInt("id"));
                itemPs.setInt(3, item.getInt("quantity"));
                itemPs.setDouble(4, item.getDouble("price"));
                itemPs.executeUpdate();
            }

            conn.close();

            response.setContentType("application/json");
            response.getWriter().print("{\"success\":true,\"orderId\":" + orderId + "}");

        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("application/json");
            response.getWriter().print("{\"success\":false}");
        }
    }
}