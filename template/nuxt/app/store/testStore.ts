import { defineStore } from 'pinia'

export const useTestStore = defineStore('test', {
  state: () => ({
    datas: Array(),
  }),

  actions: {
    async addData() {
      this.datas.push('item')
    }
  },

  getters: {
    // Obtenir tous les compilations
    getDatas: (state) => state.datas
  }
})
