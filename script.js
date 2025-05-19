document.addEventListener("DOMContentLoaded", async () => {
  const tableBody = document.getElementById("table-body");
  let apiData = [];

  try {
    const res = await fetch("https://jsonplaceholder.typicode.com/users");
    apiData = await res.json();
  } catch (e) {
    console.log("حدث خطأ");
  }

  let localData = JSON.parse(localStorage.getItem("customData")) || [];

  let allData = apiData.map(user => ({
    name: user.name,
    email: user.email,
    phone: user.phone,
    isLocal: false
  })).concat(localData.map(user => ({
    ...user,
    isLocal: true
  })));

  tableBody.innerHTML = "";
  allData.forEach((user, i) => {
    let tr = document.createElement("tr");
    let actionButtons = "";

    if (user.isLocal) {
      const localIndex = i - apiData.length;
      actionButtons = `
        <button class="update-btn" onclick="editRow(${localIndex})">Update</button>
        <button class="delete-btn" onclick="deleteRow(${localIndex})">Delete</button>
      `;
    } else {
      actionButtons = `
        <button class="update-btn" disabled>Update</button>
        <button class="delete-btn" disabled>Delete</button>
      `;
    }

    tr.innerHTML = `
      <td>${user.name}</td>
      <td>${user.email}</td>
      <td>${user.phone}</td>
      <td>${actionButtons}</td>
    `;
    tableBody.appendChild(tr);
  });
});

function editRow(i) {
  localStorage.setItem("editIndex", i);
  window.location.href = "update.html";
}

function deleteRow(i) {
  let data = JSON.parse(localStorage.getItem("customData")) || [];
  data.splice(i, 1);
  localStorage.setItem("customData", JSON.stringify(data));
  location.reload();
}
