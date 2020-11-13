const ap = new APlayer({
    container: document.getElementById('aplayer'),
    fixed: true,
    autoplay: false,
    audio: [
      {
        name: 'Viva La Vida',
        artist: 'Coldplay',
        url: 'https://ne01-sycdn.kuwo.cn/25abffcb90b9f3da1095c8442e6b515c/5fadf981/resource/n3/75/73/1831346646.mp3',
        cover: 'http://img2.sycdn.kuwo.cn/star/albumcover/300/90/80/2251451924.jpg',
      },
      {
        name: 'In This River',
        artist: 'Black Label Society',
        url: 'https://win-web-rb01-sycdn.kuwo.cn/ae13c6ddcfa82740bb22eb1ed9e621db/5fadf800/resource/n3/98/11/1729172873.mp3',
        cover: 'http://img1.kuwo.cn/star/albumcover/300/82/19/2916131621.jpg',
      }
    ]
    
});