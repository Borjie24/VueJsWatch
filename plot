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
