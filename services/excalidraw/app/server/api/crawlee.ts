import { CheerioCrawler } from 'crawlee'

const results:{}[] = []

const crawler = new CheerioCrawler({
  requestHandler ({ $, request }) {
    $('article').each((index, el) => {
      results.push({
        title: $('h3', el).text(),
        desc: $('p', el).text(),
        image: $('img', el).attr('src'),
        date: $('time', el).text()
      })
    })
  }
})

export default eventHandler(async (req) => {
  await crawler.run(['https://github.blog/category/open-source/'])

  return results
})
