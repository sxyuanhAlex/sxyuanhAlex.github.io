const ap = new APlayer({
    container: document.getElementById('aplayer'),
    fixed: true,
    autoplay: false,
    audio: [
      {
        name: 'Viva La Vida',
        artist: 'Coldplay',
        url: 'https://rp01-sycdn.kuwo.cn/3029abd00c169165c80652c91fa389fa/5d8e38ae/resource/n2/26/66/3590184758.mp3',
        cover: 'http://img2.sycdn.kuwo.cn/star/albumcover/300/90/80/2251451924.jpg',
      },
      {
        name: '常夜灯',
        artist: '玉置浩二',
        url: 'https://win-web-ra01-sycdn.kuwo.cn/c3336f679a957936e4704b8c36311687/5d8e3959/resource/n1/128/60/9/2438811764.mp3',
        cover: 'http://img3.kuwo.cn/star/albumcover/300/40/13/1229638794.jpg',
      },
      {
        name: 'In This River',
        artist: 'Black Label Society',
        url: 'https://win-web-rg01-sycdn.kuwo.cn/dfb5ea87599ab569b47c901bab065f60/5d8e3676/resource/n1/66/41/1809995527.mp3',
        cover: 'http://img1.kuwo.cn/star/albumcover/300/82/19/2916131621.jpg',
      },
      {
        name: '融化',
        artist: '梁博',
        url: 'https://win-web-rg01-sycdn.kuwo.cn/3e57e876391030429e6883dfcdcef995/5d8e3fb4/resource/n3/12/78/2938450662.mp3',
        cover: 'http://img4.kuwo.cn/star/albumcover/120/86/67/1941541207.jpg',
      }
    ]
    
});