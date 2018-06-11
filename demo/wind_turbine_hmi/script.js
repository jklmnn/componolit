google.charts.load('current', {'packages':['gauge', 'line', 'corechart']});
google.charts.setOnLoadCallback(drawChart);

function drawChart() {

    var active = true;
    var time = 0;
    var powerValue = 120;
    var speedValue = 8;

    function getRandomPower() {
        var randomValue = 0;
        if (active) {
            randomValue = 25 * speedValue + 10 * Math.random() - 5;
        }
        var value = Math.round(randomValue * 0.2 + powerValue * 0.8);
        if (value < 0)
            value = 0;
        return value;
    }

    function getRandomSpeed() {
        var value = parseFloat((speedValue + 2 * Math.random() - 1).toFixed(1));
        if (value < 0)
            value = 0;
        if (value > 20)
            value = 20;
        return value;
    }

    function setActive() {
        active = true;
        document.getElementById('state').innerHTML = 'active';
        document.getElementById('state').style.backgroundColor = '#009641';
    }

    function setInactive() {
        active = false;
        document.getElementById('state').innerHTML = 'inactive';
        document.getElementById('state').style.backgroundColor = '#999999';
    }

    setActive();

    // Initial Data
    var data = []
    for (; time < 100; time++) {
        powerValue = getRandomPower();
        speedValue = getRandomSpeed();
        data.push([time, powerValue, speedValue]);
    }

    // Wind Gauge
    var windGaugeData = google.visualization.arrayToDataTable([
        ['Label', 'Value'],
        ['Wind [m/s]', speedValue]
    ]);
    var windGaugeOptions = {
        width: 250, height: 250,
        greenFrom: 0, greenTo: 18, greenColor: '#009641',
        yellowFrom: 18, yellowTo: 20, yellowColor: '#f0a848',
        max: 20,
        minorTicks: 10,
        animation: {easing: 'inAndOut', duration: 1000}
    };
    var windGauge = new google.visualization.Gauge(document.getElementById('wind-gauge'));

    windGauge.draw(windGaugeData, windGaugeOptions);

    // Power Gauge
    var powerGaugeData = google.visualization.arrayToDataTable([
        ['Label', 'Value'],
        ['Power [kW]', powerValue],
    ]);
    var powerGaugeOptions = {
        width: 250, height: 250,
        greenFrom: 0, greenTo: 450, greenColor: '#009641',
        yellowFrom: 450, yellowTo: 500, yellowColor: '#f0a848',
        max: 500,
        minorTicks: 10,
        animation: {easing: 'linear', duration: 1000}
    };
    var powerGauge = new google.visualization.Gauge(document.getElementById('power-gauge'));

    powerGauge.draw(powerGaugeData, powerGaugeOptions);

    // Line Chart
    var lineData = new google.visualization.DataTable();
    lineData.addColumn('number', '');
    lineData.addColumn('number', 'Power');
    lineData.addColumn('number', 'Wind Speed');
    lineData.addRows(data);
    var lineOptions = {
        legend: { position: 'none' },
        width: 600,
        height: 300,
        series: {
            0: {axis: 'Power'},
            1: {axis: 'WindSpeed'}
        },
        axes: {
            y: {
                Power: {label: 'Power'},
                WindSpeed: {label: 'Wind Speed'}
            }
        }
    };
    var lineChart = new google.charts.Line(document.getElementById('line-chart'));

    lineChart.draw(lineData, lineOptions);

    // Periodic Update
    setInterval(function() {
        speedValue = getRandomSpeed();
        powerValue = getRandomPower();

        windGaugeData.setValue(0, 1, speedValue);
        windGauge.draw(windGaugeData, windGaugeOptions);

        powerGaugeData.setValue(0, 1, powerValue);
        powerGauge.draw(powerGaugeData, powerGaugeOptions);

        lineData.addRows([[time, powerValue, speedValue]]);
        lineChart.draw(lineData, lineOptions);
        time++;
    }, 1000);

    // Button Actions
    document.getElementById('on').onclick = function() {
        setActive();
    }

    document.getElementById('off').onclick = function() {
        setInactive();
    }

}
