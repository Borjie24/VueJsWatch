<template>
  <div class="container">
    <div ref="plot" class="plot-container"></div>
    <div class="side-bar">
      <div class="color-bar" :style="{ backgroundColor: currentColor }">
        <span class="temperature-label">{{ currentTemperature.toFixed(1) }}°C</span>
      </div>
    </div>
  </div>
</template>

<script>
import Plotly from "plotly.js-dist";

export default {
  data() {
    return {
      data: [],
      index: 0,
      intervalId: null,
      currentColor: "green", // Initial color
      currentTemperature: 0, // Current temperature value
    };
  },
  mounted() {
    this.initializePlot();
    this.startGraphing();
  },
  methods: {
    generateRandomTemperature() {
      return Math.random() * 100; // Random temperature between 0 and 100
    },
    initializePlot() {
      Plotly.newPlot(
        this.$refs.plot,
        [
          {
            x: [],
            y: [],
            type: "scatter",
            mode: "lines+markers",
            name: "Temperature",
            marker: { color: "black" },
            line: { color: "black" },
          },
          {
            x: [0, 1000], // Threshold line for 10°C
            y: [10, 10],
            type: "line",
            name: "10°C Threshold",
            line: { color: "blue", dash: "dash" },
          },
          {
            x: [0, 1000], // Threshold line for 40°C
            y: [40, 40],
            type: "line",
            name: "40°C Threshold",
            line: { color: "red", dash: "dash" },
          },
        ],
        {
          title: "Temperature Data",
          xaxis: { title: "Time (seconds)", range: [0, 50] }, // Start with a smaller range
          yaxis: { title: "Temperature (°C)", range: [0, 100] },
          legend: { orientation: "h", x: 0, y: -0.2 },
        }
      );
    },
    updatePlot(temp) {
      const x = this.index;
      const y = temp;

      // Determine the color based on temperature
      this.currentColor =
        temp > 40 ? "red" : temp < 10 ? "blue" : "green";

      // Update the current temperature
      this.currentTemperature = temp;

      // Update the graph
      Plotly.extendTraces(
        this.$refs.plot,
        {
          x: [[x]],
          y: [[y]],
        },
        [0]
      );

      // Adjust x-axis range dynamically to avoid crowding
      const layoutUpdate = {};
      if (x > 50) {
        layoutUpdate["xaxis.range"] = [x - 50, x];
      }
      Plotly.relayout(this.$refs.plot, layoutUpdate);
    },
    startGraphing() {
      this.intervalId = setInterval(() => {
        const temp = this.generateRandomTemperature();
        this.updatePlot(temp);
        this.index++;
        if (this.index >= 1000) clearInterval(this.intervalId);
      }, 1000);
    },
  },
};
</script>

<style scoped>
.container {
  display: flex;
  align-items: center;
}
.plot-container {
  flex: 1;
  height: 500px;
}
.side-bar {
  width: 50px;
  height: 500px;
  display: flex;
  justify-content: center;
  align-items: center;
  flex-direction: column;
  margin-left: 10px;
}
.color-bar {
  width: 100%;
  height: 100%;
  display: flex;
  justify-content: center;
  align-items: center;
  transition: background-color 0.5s ease;
  border-radius: 5px;
  position: relative;
}
.temperature-label {
  position: absolute;
  color: white;
  font-size: 14px;
  font-weight: bold;
  writing-mode: vertical-rl; /* Vertical text */
  text-orientation: mixed;
  text-shadow: 0 0 5px black;
}
</style>
---------------------------
import { shallowMount } from '@vue/test-utils';
import TemperatureGraph from '@/components/TemperatureGraph.vue';
import Plotly from 'plotly.js-dist';

jest.mock('plotly.js-dist', () => ({
  newPlot: jest.fn(),
  extendTraces: jest.fn(),
  relayout: jest.fn(),
}));

describe('TemperatureGraph.vue', () => {
  let wrapper;

  beforeEach(() => {
    jest.useFakeTimers(); // Use fake timers for interval testing
    wrapper = shallowMount(TemperatureGraph);
  });

  afterEach(() => {
    jest.clearAllTimers();
    jest.restoreAllMocks();
    wrapper.destroy();
  });

  test('renders the component correctly', () => {
    expect(wrapper.find('.plot-container').exists()).toBe(true);
    expect(wrapper.find('.side-bar').exists()).toBe(true);
    expect(Plotly.newPlot).toHaveBeenCalled();
  });

  test('initializes the graph with correct axis ranges', () => {
    const layout = Plotly.newPlot.mock.calls[0][2];
    expect(layout.xaxis.range).toEqual([0, 50]);
    expect(layout.yaxis.range).toEqual([0, 100]);
  });

  test('generates valid random temperatures', () => {
    for (let i = 0; i < 10; i++) {
      const temp = wrapper.vm.generateRandomTemperature();
      expect(temp).toBeGreaterThanOrEqual(0);
      expect(temp).toBeLessThanOrEqual(100);
    }
  });

  test('updates the graph with correct data and sidebar color', () => {
    const temp = 45; // Simulate a temperature above 40°C
    wrapper.vm.updatePlot(temp);

    // Check Plotly.extendTraces was called with the correct data
    expect(Plotly.extendTraces).toHaveBeenCalledWith(
      wrapper.vm.$refs.plot,
      { x: [[0]], y: [[temp]] },
      [0]
    );

    // Check sidebar color
    expect(wrapper.vm.currentColor).toBe('red');
    expect(wrapper.vm.currentTemperature).toBe(temp);
  });

  test('updates the sidebar for temperatures below 10°C', () => {
    const temp = 5; // Simulate a temperature below 10°C
    wrapper.vm.updatePlot(temp);

    expect(wrapper.vm.currentColor).toBe('blue');
    expect(wrapper.vm.currentTemperature).toBe(temp);
  });

  test('adjusts the x-axis range dynamically', () => {
    for (let i = 0; i <= 55; i++) {
      wrapper.vm.updatePlot(20); // Simulate 55 data points
    }

    // Check x-axis range adjustment
    expect(Plotly.relayout).toHaveBeenCalledWith(wrapper.vm.$refs.plot, {
      'xaxis.range': [5, 55],
    });
  });

  test('starts graphing and stops after 1000 points', () => {
    wrapper.vm.startGraphing();

    // Fast-forward time to simulate intervals
    jest.advanceTimersByTime(1000 * 1000);

    expect(wrapper.vm.index).toBe(1000);
    expect(clearInterval).toHaveBeenCalled();
  });
});
