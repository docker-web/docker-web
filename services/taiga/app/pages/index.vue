<template>
  <UContainer>
    <UTabs :items="items">
      <template #default="{ item, index, selected }">
        <div class="flex items-center gap-2 relative truncate">
          <UIcon :name="item.icon" class="w-4 h-4 flex-shrink-0" />
          <span class="truncate">{{ index + 1 }}. {{ item.label }}</span>
          <span v-if="selected" class="absolute -right-4 w-2 h-2 rounded-full bg-primary-500 dark:bg-primary-400" />
        </div>
      </template>
      <template #item="{ item }">
        <Ui v-if="item.label === 'UI'" />
        <Crawlee v-if="item.label === 'Crawlee'" />
        <Pinia v-if="item.label === 'Pinia'" />
      </template>
    </UTabs>
  </UContainer>
</template>

<script>
export default {
  data () {
    return {
      items: [
        {
          label: 'Crawlee',
          icon: 'i-heroicons-sparkles'
        },
        {
          label: 'UI',
          icon: 'i-heroicons-photo'
        },
        {
          label: 'Pinia',
          icon: 'i-heroicons-circle-stack'
        }
      ]
    }
  }
}
</script>
