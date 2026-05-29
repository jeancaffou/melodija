<template>
  <div
    class="dos-intro"
    :role="interactive ? 'button' : 'img'"
    :tabindex="interactive ? 0 : -1"
    @click="handleEnter"
  >
    <svg
      class="dos-cobol-screen"
      :viewBox="`0 0 ${splashMetrics.width} ${splashMetrics.height}`"
      aria-label="Dušan Kafol Melodija"
      preserveAspectRatio="xMidYMid meet"
    >
      <defs>
        <clipPath id="dos-splash-panel-clip">
          <rect
            :x="splashMetrics.panel.x"
            :y="splashMetrics.panel.y"
            :width="splashMetrics.panel.width"
            :height="splashMetrics.panel.height"
          />
        </clipPath>
      </defs>

      <rect class="dos-splash-bg" width="100%" height="100%" />
      <g class="dos-splash-header">
        <text
          v-for="item in splashHeaderText"
          :key="`${item.text}-${item.x}-${item.y}`"
          :x="item.x"
          :y="item.y"
        >{{ item.text }}</text>
      </g>
      <g class="dos-splash-header-lines" shape-rendering="crispEdges">
        <path
          v-for="path in splashHeaderPaths"
          :key="path.d"
          :d="path.d"
        />
      </g>

      <rect
        class="dos-splash-black"
        :x="splashMetrics.panel.x"
        :y="splashMetrics.panel.y"
        :width="splashMetrics.panel.width"
        :height="splashMetrics.panel.height"
      />

      <g class="dos-splash-frame" shape-rendering="crispEdges">
        <line
          v-for="line in splashFrameLines"
          :key="`${line.x1}-${line.y1}-${line.x2}-${line.y2}`"
          :x1="line.x1"
          :y1="line.y1"
          :x2="line.x2"
          :y2="line.y2"
        />
      </g>

      <g clip-path="url(#dos-splash-panel-clip)" shape-rendering="crispEdges">
        <g class="dos-splash-dusan">
          <rect
            v-for="cell in splashBlockCells"
            :key="`dusan-${cell.x}-${cell.y}`"
            :x="cell.x"
            :y="cell.y"
            :width="cell.width"
            :height="cell.height"
          />
        </g>

        <g class="dos-splash-melodija-runs">
          <rect
            v-for="rect in splashMelodijaRuns"
            :key="`melodija-${rect.x}-${rect.y}-${rect.width}-${rect.height}-${rect.color}`"
            :class="`is-${rect.color}`"
            :x="rect.x"
            :y="rect.y"
            :width="rect.width"
            :height="rect.height"
          />
        </g>
      </g>
    </svg>
  </div>
</template>

<script setup>
import {
  splashBlockCells,
  splashFrameLines,
  splashHeaderPaths,
  splashHeaderText,
  splashMelodijaRuns,
  splashMetrics
} from '../cobolSplash.js';

const props = defineProps({
  interactive: {
    type: Boolean,
    default: true
  }
});

const emit = defineEmits(['enter']);

function handleEnter() {
  if (props.interactive) {
    emit('enter');
  }
}
</script>
