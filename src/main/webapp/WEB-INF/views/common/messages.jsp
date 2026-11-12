<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String successMsg = (String) request.getAttribute("successMessage");
    String errorMsg = (String) request.getAttribute("errorMessage");
    String infoMsg = (String) request.getAttribute("infoMessage");
%>
<% if (successMsg != null && !successMsg.trim().isEmpty()) { %>
    <div class="alert alert-success" role="alert">
        <svg width="20" height="20" viewBox="0 0 20 20" fill="currentColor">
            <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
        </svg>
        <span><%= com.campusflow.util.SecurityUtil.escapeHtml(successMsg) %></span>
    </div>
<% } %>

<% if (errorMsg != null && !errorMsg.trim().isEmpty()) { %>
    <div class="alert alert-danger" role="alert">
        <svg width="20" height="20" viewBox="0 0 20 20" fill="currentColor">
            <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clip-rule="evenodd"/>
        </svg>
        <span><%= com.campusflow.util.SecurityUtil.escapeHtml(errorMsg) %></span>
    </div>
<% } %>

<% if (infoMsg != null && !infoMsg.trim().isEmpty()) { %>
    <div class="alert alert-info" role="alert">
        <svg width="20" height="20" viewBox="0 0 20 20" fill="currentColor">
            <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd"/>
        </svg>
        <span><%= com.campusflow.util.SecurityUtil.escapeHtml(infoMsg) %></span>
    </div>
<% } %>
