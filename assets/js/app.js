// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import './user_socket.js'

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import '../vendor/some-package.js'
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import 'some-package'
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import 'phoenix_html'
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from 'phoenix'
import {LiveSocket} from 'phoenix_live_view'
import topbar from '../vendor/topbar'

import * as d3 from 'd3';

const GEOJSON = 'https://raw.githubusercontent.com/nvkelso/natural-earth-vector/master/geojson/ne_110m_land.geojson'
const MAPPING = { 'ruby': 'red', 'python': 'blue', 'javascript': 'yellow' }
const BUFFER_MAX = 1000

let Hooks = {
    DrawMap: {
        mounted() {
            let projection = d3.geoNaturalEarth1()
            let geoGenerator = d3.geoPath().projection(projection)
            let svg = d3.select(this.el)
            let map_group = svg.append('g').attr('id', 'map')
            let blips_group = svg.append('g').attr('id', 'blips')

            d3.json(GEOJSON).then((json) => {
                map_group.selectAll('path')
                    .data(json.features)
                    .join('path')
                    .attr('d', geoGenerator)
                    .attr('class', 'fill-violet-200 stroke-neutral-400')
            })

            this.handleEvent('feed', entry => {
                if (blips_group.selectChildren().size() > BUFFER_MAX) {
                    blips_group.selectChild().remove()
                }

                let { latitude, longitude, time, platform } = entry
                let [ long, lat ] = projection([longitude, latitude])

                blips_group.append('circle')
                    .attr('id', time)
                    .attr('cx', long)
                    .attr('cy', lat)
                    .attr('r', 3)
                    .style('fill', MAPPING[platform])
            })
        }
    }
}

let csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
let liveSocket = new LiveSocket('/live', Socket, {
    longPollFallbackMs: 2500,
    params: {_csrf_token: csrfToken},
    hooks: Hooks
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: '#29d'}, shadowColor: 'rgba(0, 0, 0, .3)'})
window.addEventListener('phx:page-loading-start', _info => topbar.show(300))
window.addEventListener('phx:page-loading-stop', _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()
liveSocket.disableDebug()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket
