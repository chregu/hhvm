<?php

function newrelic_profiling_enable(int $level) {
  xhprof_enable(256,array(0 => $level));
}


function newrelic_profiling_disable() {
    xhprof_disable();
}

