package com.doormart.doormart;

import java.io.*;
import java.sql.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        try {
            Connection conn = DBConnection.getConnection();
            
            String sql = "SELECT * FROM users WHERE email = ? AND password = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, email);
            ps.setString(2, password);
            ResultSet rs = ps.executeQuery();
            
            System.out.println("Email: " + email + " Password: " + password);

            if (rs.next()) {
                // Login successful — save user info in session
                HttpSession session = request.getSession();
                session.setAttribute("userId", rs.getInt("id"));
                session.setAttribute("userName", rs.getString("name"));
                session.setAttribute("userRole", rs.getString("role"));
           
                // Redirect based on role
                String role = rs.getString("role");
                conn.close();
               
                if (role.equals("owner")) {
                    response.sendRedirect("http://localhost:8080/DoorMart/owner/dashboard.jsp");
                } else {
                    response.sendRedirect("http://localhost:8080/DoorMart/customer/shops.jsp");
                }

            } else {
                // Login failed
                response.sendRedirect("http://localhost:8080/DoorMart/login.html?error=invalid");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("http://localhost:8080/DoorMart/login.html?error=failed");
        }
    }
}