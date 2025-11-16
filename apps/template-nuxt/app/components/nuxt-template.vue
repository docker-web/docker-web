<template>
  <h1 class="flex flex-col gap-y-4 items-center justify-center flex items-center justify-center min-h-screen">
    <img src="/logo.svg" />
    <div class="absolute top-4 right-4">
      <button class="block p-4 bg-black text-slate-400" @click="store.addData()">add to 🍍</button>
      <pre>
      {{ store.getDatas }}
    </pre>
    </div>
  </h1>
</template>

<script setup>
import { useTestStore } from '@/store/testStore'
const store = useTestStore()
</script>
