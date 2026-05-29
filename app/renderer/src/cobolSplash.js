const SCREEN_WIDTH = 80;
const SCREEN_HEIGHT = 24;
const VIEW_WIDTH = 640;
const VIEW_HEIGHT = 336;
const CELL_WIDTH = VIEW_WIDTH / SCREEN_WIDTH;
const CELL_HEIGHT = VIEW_HEIGHT / SCREEN_HEIGHT;

const COBOL_ROWS = [
  '                ┌───┐ ┌──┐ ┌┐  ┌┐ ┌──   ┌┐ │                   Pivška 6         ',
  '    Copyright   │     │  │ │└┐┌┘│ ├─  │ │└┐│                   6230 Postojna    ',
  '                └───┘ └──┘ │ └┘ │ │   │ │ └┘                   tel. 067/25-038  ',
  '                 │  │ ┌┐ ││┌┘┌─┐     ┌ ─┬─┌─┌─ ┌─│                              ',
  '                 └┐┌┘││└┐│├┤ │ │     └┐ │ ├ │┌┐├ │                              ',
  '                  └┘ ││ └┘│└┐└─┘     ─┘ │ └─└─┘└─└─                             ',
  '┌──────────────────────────────────────────────────────────────────────────────┐',
  '│                █  ▀▀            █      █                                     │',
  '│       ████  █  █ ████ █████ ██  █      █  █ █████ █████ █████ █              │',
  '│       █   █ █  █ █    █   █ ███ █      █ ██ █   █ █   █   █ █                │',
  '│       █   █ █  █ ████ █████ █ ███      ███  █████ ███   █   █ █              │',
  '│       █   █ █  █    █ █   █ █  ██      █ ██ █   █ █   █   █ █                │',
  '│       █   █ ████ ████ █   █ █  ██      █  █ █   █ █   █████ █                │',
  '│       ████                █ █             █     █ █         █████            │',
  '│                                                                              │',
  '│     ┌─┐    ┌─┐ ┌──────┐ ┌─┐      ┌──────┐ ┌─────┐  ┌─┐      ┌─┐ ┌──────┐     │',
  '│     │ └┐  ┌┘ │ │ ┌────┘ │ │      │ ┌──┐ │ │ ┌─┐ └┐ │ │      │ │ │ ┌──┐ │     │',
  '│     │  └──┘  │ │ │      │ │      │ │  │ │ │ │ └┐ │ │ │      │ │ │ │  │ │     │',
  '│     │        │ │ └──┐   │ │      │ │  │ │ │ │  │ │ │ │      │ │ │ └──┘ │     │',
  '│     │ ┌┐  ┌┐ │ │ ┌──┘   │ │      │ │  │ │ │ │  │ │ │ │      │ │ │ ┌──┐ │     │',
  '│     │ │└──┘│ │ │ │      │ │      │ │  │ │ │ │ ┌┘ │ │ │ ┌─┐  │ │ │ │  │ │     │',
  '│     │ │    │ │ │ └────┐ │ └────┐ │ └──┘ │ │ └─┘ ┌┘ │ │ │ └──┘ │ │ │  │ │     │',
  '│     └─┘    └─┘ └──────┘ └──────┘ └──────┘ └─────┘└─┘ └──────┘ └─┘  └─┘       │',
  '└──────────────────────────────────────────────────────────────────────────────┘'
];

const DUSAN_BLOCK_ROWS = [
  '                 █  ▀▀            █      █                                      ',
  '        ████  █  █ ████ █████ ██  █      █  █ █████ █████ █████ █               ',
  '        █   █ █  █ █    █   █ ███ █      █ ██ █   █ █     █   █ █               ',
  '        █   █ █  █ ████ █████ █ ███      ███  █████ ███   █   █ █               ',
  '        █   █ █  █    █ █   █ █  ██      █ ██ █   █ █     █   █ █               ',
  '        █   █ ████ ████ █   █ █  ██      █  █ █   █ █     █████ █               ',
  '        ████                █ █             █     █ █           █████           '
];

const MELODIJA_TEAL_RANGES = {
  16: [[8, 9], [15, 16], [19, 25], [28, 29], [37, 43], [46, 51], [55, 56], [64, 65], [68, 74]],
  17: [[8, 9], [14, 16], [19, 20], [28, 29], [37, 43], [46, 47], [50, 52], [55, 56], [64, 65], [68, 69], [73, 74]],
  18: [[8, 10], [13, 16], [19, 20], [28, 29], [37, 38], [41, 43], [46, 47], [51, 52], [55, 56], [64, 65], [68, 69], [73, 74]],
  19: [[8, 16], [19, 23], [28, 29], [37, 38], [41, 43], [46, 47], [51, 52], [55, 56], [64, 65], [68, 69], [73, 74]],
  20: [[8, 16], [19, 20], [28, 29], [37, 38], [41, 43], [46, 47], [51, 52], [55, 56], [64, 65], [68, 74]],
  21: [[8, 9], [11, 13], [15, 16], [19, 20], [28, 29], [37, 38], [41, 43], [46, 47], [50, 52], [55, 56], [59, 60], [64, 65], [68, 69], [73, 74]],
  22: [[8, 9], [15, 16], [19, 25], [28, 34], [37, 43], [46, 51], [55, 56], [59, 65], [68, 69], [73, 74]]
};

function inRange(col, ranges = []) {
  return ranges.some(([start, end]) => col >= start && col <= end);
}

function makeCell(char, line, col) {
  let fg = 5;
  let bg = 0;

  if (line <= 7 || line === 24) {
    fg = 0;
    bg = 3;
  } else if (col === 1 || col === SCREEN_WIDTH) {
    fg = 0;
    bg = 3;
  } else if (inRange(col, MELODIJA_TEAL_RANGES[line])) {
    fg = 5;
    bg = 3;
  }

  return { char, fg, bg };
}

export const cobolSplashRows = COBOL_ROWS.map((row, rowIndex) => {
  const line = rowIndex + 1;
  const chars = [...row.padEnd(SCREEN_WIDTH, ' ').slice(0, SCREEN_WIDTH)];
  return chars.map((char, colIndex) => makeCell(char, line, colIndex + 1));
});

const melodijaFillRanges = Object.entries(MELODIJA_TEAL_RANGES).flatMap(([line, ranges]) => (
  ranges.map(([start, end]) => ({ line: Number(line), start, end }))
));

export const splashMetrics = {
  width: VIEW_WIDTH,
  height: VIEW_HEIGHT,
  columns: SCREEN_WIDTH,
  rows: SCREEN_HEIGHT,
  cellWidth: CELL_WIDTH,
  cellHeight: CELL_HEIGHT,
  panel: {
    x: CELL_WIDTH,
    y: CELL_HEIGHT * 7,
    width: CELL_WIDTH * 78,
    height: CELL_HEIGHT * 16
  }
};

export const splashHeaderText = [
  { text: 'Copyright', col: 5, line: 2 },
  { text: 'Pivška 6', col: 64, line: 1 },
  { text: '6230 Postojna', col: 64, line: 2 },
  { text: 'tel. 067/25-038', col: 64, line: 3 }
].map((item) => ({
  ...item,
  x: (item.col - 1) * CELL_WIDTH,
  y: ((item.line - 1) * CELL_HEIGHT) + (CELL_HEIGHT * 0.8)
}));

export const splashFrameLines = [
  {
    x1: CELL_WIDTH / 2,
    y1: (CELL_HEIGHT * 6) + (CELL_HEIGHT / 2),
    x2: (SCREEN_WIDTH - 0.5) * CELL_WIDTH,
    y2: (CELL_HEIGHT * 6) + (CELL_HEIGHT / 2)
  },
  {
    x1: CELL_WIDTH / 2,
    y1: (CELL_HEIGHT * 23) + (CELL_HEIGHT / 2),
    x2: (SCREEN_WIDTH - 0.5) * CELL_WIDTH,
    y2: (CELL_HEIGHT * 23) + (CELL_HEIGHT / 2)
  },
  {
    x1: CELL_WIDTH / 2,
    y1: (CELL_HEIGHT * 6) + (CELL_HEIGHT / 2),
    x2: CELL_WIDTH / 2,
    y2: (CELL_HEIGHT * 23) + (CELL_HEIGHT / 2)
  },
  {
    x1: (SCREEN_WIDTH - 0.5) * CELL_WIDTH,
    y1: (CELL_HEIGHT * 6) + (CELL_HEIGHT / 2),
    x2: (SCREEN_WIDTH - 0.5) * CELL_WIDTH,
    y2: (CELL_HEIGHT * 23) + (CELL_HEIGHT / 2)
  }
];

export const splashBlockCells = DUSAN_BLOCK_ROWS.flatMap((row, index) => {
  const line = index + 8;
  return [...row.padEnd(SCREEN_WIDTH, ' ').slice(0, SCREEN_WIDTH)].flatMap((char, colIndex) => {
    if (char !== '█' && char !== '▀') return [];
    const x = colIndex * CELL_WIDTH;
    const y = (line - 1) * CELL_HEIGHT;
    return [{
      x,
      y,
      width: CELL_WIDTH,
      height: char === '▀' ? CELL_HEIGHT / 2 : CELL_HEIGHT
    }];
  });
});

export const splashFillRects = melodijaFillRanges.map((range) => ({
  x: (range.start - 1) * CELL_WIDTH,
  y: (range.line - 1) * CELL_HEIGHT,
  width: (range.end - range.start + 1) * CELL_WIDTH,
  height: CELL_HEIGHT
}));

function segmentRect(x, y, width, height) {
  return {
    x: Math.round(x),
    y: Math.round(y),
    width: Math.round(width),
    height: Math.round(height)
  };
}

function lineRectsFor(char, x, y) {
  const left = x;
  const right = x + CELL_WIDTH;
  const top = y;
  const bottom = y + CELL_HEIGHT;
  const midX = Math.round(x + (CELL_WIDTH / 2));
  const midY = Math.round(y + (CELL_HEIGHT / 2));

  switch (char) {
    case '─':
      return [segmentRect(left, midY, CELL_WIDTH, 1)];
    case '│':
      return [segmentRect(midX, top, 1, CELL_HEIGHT)];
    case '┌':
      return [
        segmentRect(midX, midY, 1, bottom - midY),
        segmentRect(midX, midY, right - midX, 1)
      ];
    case '┐':
      return [
        segmentRect(left, midY, midX - left + 1, 1),
        segmentRect(midX, midY, 1, bottom - midY)
      ];
    case '└':
      return [
        segmentRect(midX, top, 1, midY - top + 1),
        segmentRect(midX, midY, right - midX, 1)
      ];
    case '┘':
      return [
        segmentRect(left, midY, midX - left + 1, 1),
        segmentRect(midX, top, 1, midY - top + 1)
      ];
    case '├':
      return [
        segmentRect(midX, top, 1, CELL_HEIGHT),
        segmentRect(midX, midY, right - midX, 1)
      ];
    case '┤':
      return [
        segmentRect(midX, top, 1, CELL_HEIGHT),
        segmentRect(left, midY, midX - left + 1, 1)
      ];
    case '┬':
      return [
        segmentRect(left, midY, CELL_WIDTH, 1),
        segmentRect(midX, midY, 1, bottom - midY)
      ];
    default:
      return [];
  }
}

function linePathFor(char, x, y) {
  const left = x;
  const right = x + CELL_WIDTH;
  const top = y;
  const bottom = y + CELL_HEIGHT;
  const midX = Math.round(x + (CELL_WIDTH / 2)) + 0.5;
  const midY = Math.round(y + (CELL_HEIGHT / 2)) + 0.5;

  switch (char) {
    case '─':
      return `M ${left} ${midY} H ${right}`;
    case '│':
      return `M ${midX} ${top} V ${bottom}`;
    case '┌':
      return `M ${midX} ${bottom} V ${midY} H ${right}`;
    case '┐':
      return `M ${left} ${midY} H ${midX} V ${bottom}`;
    case '└':
      return `M ${midX} ${top} V ${midY} H ${right}`;
    case '┘':
      return `M ${left} ${midY} H ${midX} V ${top}`;
    case '├':
      return `M ${midX} ${top} V ${bottom} M ${midX} ${midY} H ${right}`;
    case '┤':
      return `M ${midX} ${top} V ${bottom} M ${left} ${midY} H ${midX}`;
    case '┬':
      return `M ${left} ${midY} H ${right} M ${midX} ${midY} V ${bottom}`;
    default:
      return '';
  }
}

export const splashHeaderPaths = COBOL_ROWS.slice(0, 6).flatMap((row, rowIndex) => (
  [...row.padEnd(SCREEN_WIDTH, ' ').slice(0, SCREEN_WIDTH)].flatMap((char, colIndex) => {
    const d = linePathFor(char, colIndex * CELL_WIDTH, rowIndex * CELL_HEIGHT);
    return d ? [{ d }] : [];
  })
));

const MELODIJA_REFERENCE_RUNS = [
  [56, 210, 16, 6, 'cyan'],
  [112, 210, 16, 6, 'cyan'],
  [144, 210, 56, 6, 'cyan'],
  [216, 210, 16, 6, 'cyan'],
  [288, 210, 56, 6, 'cyan'],
  [360, 210, 48, 6, 'cyan'],
  [432, 210, 16, 6, 'cyan'],
  [504, 210, 16, 6, 'cyan'],
  [536, 210, 56, 6, 'cyan'],
  [52, 216, 17, 1, 'magenta'],
  [69, 216, 3, 14, 'cyan'],
  [108, 216, 17, 1, 'magenta'],
  [125, 216, 3, 92, 'cyan'],
  [140, 216, 57, 1, 'magenta'],
  [197, 216, 3, 8, 'cyan'],
  [212, 216, 17, 1, 'magenta'],
  [229, 216, 3, 78, 'cyan'],
  [284, 216, 57, 1, 'magenta'],
  [341, 216, 3, 92, 'cyan'],
  [356, 216, 49, 1, 'magenta'],
  [405, 216, 3, 8, 'cyan'],
  [428, 216, 17, 1, 'magenta'],
  [445, 216, 3, 92, 'cyan'],
  [500, 216, 17, 1, 'magenta'],
  [517, 216, 3, 92, 'cyan'],
  [532, 216, 57, 1, 'magenta'],
  [589, 216, 3, 92, 'cyan'],
  [52, 217, 1, 97, 'magenta'],
  [56, 217, 12, 14, 'cyan'],
  [68, 217, 1, 13, 'magenta'],
  [108, 217, 1, 13, 'magenta'],
  [112, 217, 12, 7, 'cyan'],
  [124, 217, 1, 97, 'magenta'],
  [140, 217, 1, 97, 'magenta'],
  [144, 217, 52, 7, 'cyan'],
  [196, 217, 1, 13, 'magenta'],
  [212, 217, 1, 97, 'magenta'],
  [216, 217, 12, 84, 'cyan'],
  [228, 217, 1, 83, 'magenta'],
  [284, 217, 1, 97, 'magenta'],
  [288, 217, 52, 13, 'cyan'],
  [340, 217, 1, 97, 'magenta'],
  [356, 217, 1, 97, 'magenta'],
  [360, 217, 44, 7, 'cyan'],
  [404, 217, 1, 13, 'magenta'],
  [428, 217, 1, 97, 'magenta'],
  [432, 217, 12, 91, 'cyan'],
  [444, 217, 1, 97, 'magenta'],
  [500, 217, 1, 83, 'magenta'],
  [504, 217, 12, 77, 'cyan'],
  [516, 217, 1, 97, 'magenta'],
  [532, 217, 1, 97, 'magenta'],
  [536, 217, 52, 7, 'cyan'],
  [588, 217, 1, 97, 'magenta'],
  [104, 224, 4, 6, 'cyan'],
  [109, 224, 15, 7, 'cyan'],
  [144, 224, 16, 6, 'cyan'],
  [360, 224, 16, 6, 'cyan'],
  [392, 224, 12, 7, 'cyan'],
  [405, 224, 11, 6, 'cyan'],
  [536, 224, 16, 6, 'cyan'],
  [576, 224, 12, 42, 'cyan'],
  [68, 230, 9, 1, 'magenta'],
  [100, 230, 9, 1, 'magenta'],
  [144, 230, 12, 29, 'cyan'],
  [156, 230, 41, 1, 'magenta'],
  [288, 230, 12, 71, 'cyan'],
  [300, 230, 25, 1, 'magenta'],
  [325, 230, 15, 71, 'cyan'],
  [360, 230, 12, 71, 'cyan'],
  [372, 230, 17, 1, 'magenta'],
  [404, 230, 9, 1, 'magenta'],
  [413, 230, 3, 64, 'cyan'],
  [536, 230, 12, 29, 'cyan'],
  [548, 230, 25, 1, 'magenta'],
  [56, 231, 16, 7, 'cyan'],
  [76, 231, 1, 13, 'magenta'],
  [100, 231, 1, 13, 'magenta'],
  [104, 231, 20, 7, 'cyan'],
  [156, 231, 1, 27, 'magenta'],
  [157, 231, 3, 21, 'cyan'],
  [300, 231, 1, 69, 'magenta'],
  [301, 231, 23, 7, 'cyan'],
  [324, 231, 1, 69, 'magenta'],
  [372, 231, 1, 69, 'magenta'],
  [373, 231, 3, 63, 'cyan'],
  [388, 231, 1, 13, 'magenta'],
  [392, 231, 20, 7, 'cyan'],
  [412, 231, 1, 69, 'magenta'],
  [548, 231, 1, 27, 'magenta'],
  [549, 231, 3, 27, 'cyan'],
  [572, 231, 1, 27, 'magenta'],
  [56, 238, 20, 7, 'cyan'],
  [77, 238, 3, 6, 'cyan'],
  [96, 238, 4, 6, 'cyan'],
  [101, 238, 23, 7, 'cyan'],
  [301, 238, 3, 56, 'cyan'],
  [320, 238, 4, 56, 'cyan'],
  [400, 238, 12, 42, 'cyan'],
  [76, 244, 25, 1, 'magenta'],
  [388, 244, 9, 1, 'magenta'],
  [56, 245, 24, 7, 'cyan'],
  [96, 245, 28, 7, 'cyan'],
  [396, 245, 1, 41, 'magenta'],
  [56, 252, 68, 20, 'cyan'],
  [157, 252, 27, 6, 'cyan'],
  [156, 258, 25, 1, 'magenta'],
  [181, 258, 3, 8, 'cyan'],
  [548, 258, 25, 1, 'magenta'],
  [144, 259, 36, 7, 'cyan'],
  [180, 259, 1, 13, 'magenta'],
  [536, 259, 16, 7, 'cyan'],
  [144, 266, 16, 6, 'cyan'],
  [536, 266, 52, 6, 'cyan'],
  [56, 272, 12, 36, 'cyan'],
  [68, 272, 9, 1, 'magenta'],
  [77, 272, 23, 8, 'cyan'],
  [100, 272, 9, 1, 'magenta'],
  [109, 272, 15, 8, 'cyan'],
  [144, 272, 12, 29, 'cyan'],
  [156, 272, 25, 1, 'magenta'],
  [536, 272, 12, 36, 'cyan'],
  [548, 272, 25, 1, 'magenta'],
  [573, 272, 15, 8, 'cyan'],
  [68, 273, 1, 41, 'magenta'],
  [69, 273, 7, 7, 'cyan'],
  [76, 273, 1, 13, 'magenta'],
  [100, 273, 1, 13, 'magenta'],
  [101, 273, 7, 7, 'cyan'],
  [108, 273, 1, 41, 'magenta'],
  [156, 273, 1, 27, 'magenta'],
  [157, 273, 3, 21, 'cyan'],
  [548, 273, 1, 41, 'magenta'],
  [549, 273, 23, 7, 'cyan'],
  [572, 273, 1, 41, 'magenta'],
  [69, 280, 3, 28, 'cyan'],
  [80, 280, 20, 6, 'cyan'],
  [101, 280, 3, 7, 'cyan'],
  [112, 280, 12, 28, 'cyan'],
  [392, 280, 4, 6, 'cyan'],
  [397, 280, 15, 7, 'cyan'],
  [464, 280, 16, 6, 'cyan'],
  [549, 280, 3, 28, 'cyan'],
  [576, 280, 12, 28, 'cyan'],
  [76, 286, 25, 1, 'magenta'],
  [388, 286, 9, 1, 'magenta'],
  [460, 286, 17, 1, 'magenta'],
  [477, 286, 3, 8, 'cyan'],
  [80, 287, 24, 7, 'cyan'],
  [388, 287, 1, 13, 'magenta'],
  [392, 287, 20, 7, 'cyan'],
  [460, 287, 1, 27, 'magenta'],
  [464, 287, 12, 14, 'cyan'],
  [476, 287, 1, 13, 'magenta'],
  [157, 294, 43, 6, 'cyan'],
  [229, 294, 43, 6, 'cyan'],
  [301, 294, 23, 6, 'cyan'],
  [373, 294, 15, 6, 'cyan'],
  [389, 294, 19, 6, 'cyan'],
  [477, 294, 23, 6, 'cyan'],
  [501, 294, 15, 7, 'cyan'],
  [156, 300, 41, 1, 'magenta'],
  [197, 300, 3, 8, 'cyan'],
  [228, 300, 41, 1, 'magenta'],
  [269, 300, 3, 8, 'cyan'],
  [300, 300, 25, 1, 'magenta'],
  [372, 300, 17, 1, 'magenta'],
  [389, 300, 15, 1, 'cyan'],
  [404, 300, 9, 1, 'magenta'],
  [476, 300, 25, 1, 'magenta'],
  [144, 301, 52, 7, 'cyan'],
  [196, 301, 1, 13, 'magenta'],
  [216, 301, 52, 7, 'cyan'],
  [268, 301, 1, 13, 'magenta'],
  [288, 301, 52, 7, 'cyan'],
  [360, 301, 44, 7, 'cyan'],
  [404, 301, 1, 13, 'magenta'],
  [405, 301, 3, 7, 'cyan'],
  [464, 301, 52, 7, 'cyan'],
  [52, 314, 17, 1, 'magenta'],
  [108, 314, 17, 1, 'magenta'],
  [140, 314, 57, 1, 'magenta'],
  [212, 314, 57, 1, 'magenta'],
  [284, 314, 57, 1, 'magenta'],
  [356, 314, 49, 1, 'magenta'],
  [428, 314, 17, 1, 'magenta'],
  [460, 314, 57, 1, 'magenta'],
  [532, 314, 17, 1, 'magenta'],
  [572, 314, 17, 1, 'magenta']
];

export const splashMelodijaRuns = MELODIJA_REFERENCE_RUNS.map(([x, y, width, height, color]) => ({
  x,
  y,
  width,
  height,
  color
}));
