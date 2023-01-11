<template>
  <div class="bg-dark text-white p-3 vh-100">
    <h1 class="text-white h5">
      <img src="images/mslogo.png" />
      <span>Video Search</span>
    </h1>

    <hr />

    <ul class="nav nav-pills flex-column mb-auto">
      <li class="nav-item">
        <router-link to="/" class="nav-link text-white" active-class="active" exact>
          <i class="bi bi-search"></i>
          <span class="ps-1">検索</span>
        </router-link>
      </li>
      <li class="nav-item">
        <router-link to="/upload" class="nav-link text-white" active-class="active">
          <i class="bi bi-upload"></i>
          <span class="ps-1">アップロード</span>
        </router-link>
      </li>
    </ul>
  </div>
</template>

<style scoped>
nav {
  width: 200px;
}

h1 img {
  height: 25px;
  position: relative;
  top: -2px;
  margin-right: 8px;
}
</style>
