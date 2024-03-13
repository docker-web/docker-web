<script lang="ts" setup></script>

<template>
  <div>
      <UButton icon="i-heroicons-chevron-double-down" @click="crawl()">
      grab data
    </ubutton>
    <UCard class="m-4" v-if="isLoading">
      <template #header>
        <div class="rounded-xl animate-pulse bg-gray-100 dark:bg-gray-800 h-40 w-40 mb-8" />
        <h1 class="animate-pulse bg-gray-100 dark:bg-gray-800 rounded-md h-4 w-full" />
      </template>
      <p class="animate-pulse bg-gray-100 dark:bg-gray-800 rounded-md h-4 w-1/3" />
      <template #footer>
        <datetime class="animate-pulse bg-gray-100 dark:bg-gray-800 rounded-md h-4 w-2/3" />
      </template>
    </UCard>
    <UCard v-for="article in articles" :key="article.title" class="m-4" v-else>
      <template #header>
        <img :src="article.image" class="rounded-xl">
        <h1 class="text">
          {{ article.title }}
        </h1>
      </template>
      <p class="p-4">
        {{ article.desc }}
      </p>
      <template #footer>
        <datetime>
          {{ article.date }}
        </datetime>
      </template>
    </UCard>
  </div>
</template>
<script>
export default {
  data () {
    return {
      articles: [],
      isLoading: false
    }
  },
  methods: {
    async crawl () {
      this.isLoading = true
      const { data } = await useFetch('/api/crawlee')
      this.articles = data.value ? data.value : []
      this.isLoading = false
    }
  }
}
</script>
