/**
 * CampusFlow - Core Client-Side Application Script
 * Vanilla JavaScript controls for modals, responsive menus, priority preview, and staff dispatching.
 */

document.addEventListener("DOMContentLoaded", function () {
  // 1. Mobile Sidebar Toggle
  const sidebar = document.querySelector(".app-sidebar");
  const toggleBtn = document.querySelector(".btn-sidebar-toggle");
  if (toggleBtn && sidebar) {
    toggleBtn.addEventListener("click", function () {
      sidebar.classList.toggle("open");
    });
  }

  // 2. Real-Time Priority Engine Preview on Request Submission Form
  const urgencySelect = document.getElementById("urgencySelect");
  const impactSelect = document.getElementById("impactSelect");
  const locationSelect = document.getElementById("locationSelect");
  const priorityPreview = document.getElementById("priorityPreview");
  const priorityScorePreview = document.getElementById("priorityScorePreview");

  function updatePriorityPreview() {
    if (!urgencySelect || !impactSelect || !locationSelect || !priorityPreview) return;

    const u = parseInt(urgencySelect.value, 10) || 1;
    const i = parseInt(impactSelect.value, 10) || 1;
    const l = parseInt(locationSelect.value, 10) || 1;
    const score = u + i + l;

    let prio = "LOW";
    let badgeClass = "badge-low";

    if (score <= 4) {
      prio = "LOW";
      badgeClass = "badge-low";
    } else if (score <= 6) {
      prio = "MEDIUM";
      badgeClass = "badge-medium";
    } else if (score <= 8) {
      prio = "HIGH";
      badgeClass = "badge-high";
    } else {
      prio = "CRITICAL";
      badgeClass = "badge-critical";
    }

    priorityPreview.textContent = prio;
    priorityPreview.className = "badge " + badgeClass;
    if (priorityScorePreview) {
      priorityScorePreview.textContent = "Score: " + score + " / 11";
    }
  }

  if (urgencySelect && impactSelect && locationSelect) {
    urgencySelect.addEventListener("change", updatePriorityPreview);
    impactSelect.addEventListener("change", updatePriorityPreview);
    locationSelect.addEventListener("change", updatePriorityPreview);
    updatePriorityPreview();
  }

  // 3. Dynamic Staff Filtering by Department in Assignment Modal
  const deptSelect = document.getElementById("assignDeptSelect");
  const staffSelect = document.getElementById("assignStaffSelect");

  if (deptSelect && staffSelect) {
    deptSelect.addEventListener("change", function () {
      const deptId = deptSelect.value;
      staffSelect.innerHTML = '<option value="">-- Unassigned (Department Queue) --</option>';
      if (!deptId) return;

      const contextPath = document.body.getAttribute("data-context-path") || "";
      fetch(contextPath + "/admin/api/staff-by-dept?departmentId=" + encodeURIComponent(deptId))
        .then(function (res) { return res.json(); })
        .then(function (staffList) {
          staffList.forEach(function (s) {
            const opt = document.createElement("option");
            opt.value = s.userId;
            opt.textContent = s.name + " (" + s.email + ")";
            staffSelect.appendChild(opt);
          });
        })
        .catch(function (err) {
          console.error("Failed to load department staff", err);
        });
    });
  }

  // 4. Modal Open/Close Controls
  document.querySelectorAll("[data-modal-target]").forEach(function (btn) {
    btn.addEventListener("click", function () {
      const targetId = btn.getAttribute("data-modal-target");
      const modal = document.getElementById(targetId);
      if (modal) {
        modal.classList.add("active");
      }
    });
  });

  document.querySelectorAll(".modal-close, [data-modal-close]").forEach(function (btn) {
    btn.addEventListener("click", function () {
      const modal = btn.closest(".modal-overlay");
      if (modal) {
        modal.classList.remove("active");
      }
    });
  });

  document.querySelectorAll(".modal-overlay").forEach(function (overlay) {
    overlay.addEventListener("click", function (e) {
      if (e.target === overlay) {
        overlay.classList.remove("active");
      }
    });
  });

  // 5. Confirmation Dialogs
  document.querySelectorAll("[data-confirm]").forEach(function (el) {
    el.addEventListener("click", function (e) {
      const msg = el.getAttribute("data-confirm") || "Are you sure you want to proceed?";
      if (!confirm(msg)) {
        e.preventDefault();
      }
    });
  });
});
