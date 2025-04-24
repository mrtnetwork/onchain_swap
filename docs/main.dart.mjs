
// Compiles a dart2wasm-generated main module from `source` which can then
// instantiatable via the `instantiate` method.
//
// `source` needs to be a `Response` object (or promise thereof) e.g. created
// via the `fetch()` JS API.
export async function compileStreaming(source) {
  const builtins = {builtins: ['js-string']};
  return new CompiledApp(
      await WebAssembly.compileStreaming(source, builtins), builtins);
}

// Compiles a dart2wasm-generated wasm modules from `bytes` which is then
// instantiatable via the `instantiate` method.
export async function compile(bytes) {
  const builtins = {builtins: ['js-string']};
  return new CompiledApp(await WebAssembly.compile(bytes, builtins), builtins);
}

// DEPRECATED: Please use `compile` or `compileStreaming` to get a compiled app,
// use `instantiate` method to get an instantiated app and then call
// `invokeMain` to invoke the main function.
export async function instantiate(modulePromise, importObjectPromise) {
  var moduleOrCompiledApp = await modulePromise;
  if (!(moduleOrCompiledApp instanceof CompiledApp)) {
    moduleOrCompiledApp = new CompiledApp(moduleOrCompiledApp);
  }
  const instantiatedApp = await moduleOrCompiledApp.instantiate(await importObjectPromise);
  return instantiatedApp.instantiatedModule;
}

// DEPRECATED: Please use `compile` or `compileStreaming` to get a compiled app,
// use `instantiate` method to get an instantiated app and then call
// `invokeMain` to invoke the main function.
export const invoke = (moduleInstance, ...args) => {
  moduleInstance.exports.$invokeMain(args);
}

class CompiledApp {
  constructor(module, builtins) {
    this.module = module;
    this.builtins = builtins;
  }

  // The second argument is an options object containing:
  // `loadDeferredWasm` is a JS function that takes a module name matching a
  //   wasm file produced by the dart2wasm compiler and returns the bytes to
  //   load the module. These bytes can be in either a format supported by
  //   `WebAssembly.compile` or `WebAssembly.compileStreaming`.
  async instantiate(additionalImports, {loadDeferredWasm} = {}) {
    let dartInstance;

    // Prints to the console
    function printToConsole(value) {
      if (typeof dartPrint == "function") {
        dartPrint(value);
        return;
      }
      if (typeof console == "object" && typeof console.log != "undefined") {
        console.log(value);
        return;
      }
      if (typeof print == "function") {
        print(value);
        return;
      }

      throw "Unable to print message: " + js;
    }

    // Converts a Dart List to a JS array. Any Dart objects will be converted, but
    // this will be cheap for JSValues.
    function arrayFromDartList(constructor, list) {
      const exports = dartInstance.exports;
      const read = exports.$listRead;
      const length = exports.$listLength(list);
      const array = new constructor(length);
      for (let i = 0; i < length; i++) {
        array[i] = read(list, i);
      }
      return array;
    }

    // A special symbol attached to functions that wrap Dart functions.
    const jsWrappedDartFunctionSymbol = Symbol("JSWrappedDartFunction");

    function finalizeWrapper(dartFunction, wrapped) {
      wrapped.dartFunction = dartFunction;
      wrapped[jsWrappedDartFunctionSymbol] = true;
      return wrapped;
    }

    // Imports
    const dart2wasm = {

      _1: (x0,x1,x2) => x0.set(x1,x2),
      _2: (x0,x1,x2) => x0.set(x1,x2),
      _3: (x0,x1) => x0.transferFromImageBitmap(x1),
      _4: x0 => x0.arrayBuffer(),
      _5: (x0,x1) => x0.transferFromImageBitmap(x1),
      _6: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._6(f,arguments.length,x0) }),
      _7: x0 => new window.FinalizationRegistry(x0),
      _8: (x0,x1,x2,x3) => x0.register(x1,x2,x3),
      _9: (x0,x1) => x0.unregister(x1),
      _10: (x0,x1,x2) => x0.slice(x1,x2),
      _11: (x0,x1) => x0.decode(x1),
      _12: (x0,x1) => x0.segment(x1),
      _13: () => new TextDecoder(),
      _14: x0 => x0.buffer,
      _15: x0 => x0.wasmMemory,
      _16: () => globalThis.window._flutter_skwasmInstance,
      _17: x0 => x0.rasterStartMilliseconds,
      _18: x0 => x0.rasterEndMilliseconds,
      _19: x0 => x0.imageBitmaps,
      _192: x0 => x0.select(),
      _193: (x0,x1) => x0.append(x1),
      _194: x0 => x0.remove(),
      _197: x0 => x0.unlock(),
      _202: x0 => x0.getReader(),
      _211: x0 => new MutationObserver(x0),
      _220: (x0,x1) => new OffscreenCanvas(x0,x1),
      _222: (x0,x1,x2) => x0.addEventListener(x1,x2),
      _223: (x0,x1,x2) => x0.removeEventListener(x1,x2),
      _226: x0 => new ResizeObserver(x0),
      _229: (x0,x1) => new Intl.Segmenter(x0,x1),
      _230: x0 => x0.next(),
      _231: (x0,x1) => new Intl.v8BreakIterator(x0,x1),
      _308: x0 => x0.close(),
      _309: (x0,x1,x2,x3,x4) => ({type: x0,data: x1,premultiplyAlpha: x2,colorSpaceConversion: x3,preferAnimation: x4}),
      _310: x0 => new window.ImageDecoder(x0),
      _311: x0 => x0.close(),
      _312: x0 => ({frameIndex: x0}),
      _313: (x0,x1) => x0.decode(x1),
      _316: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._316(f,arguments.length,x0) }),
      _317: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._317(f,arguments.length,x0) }),
      _318: (x0,x1) => ({addView: x0,removeView: x1}),
      _319: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._319(f,arguments.length,x0) }),
      _320: f => finalizeWrapper(f, function() { return dartInstance.exports._320(f,arguments.length) }),
      _321: (x0,x1) => ({initializeEngine: x0,autoStart: x1}),
      _322: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._322(f,arguments.length,x0) }),
      _323: x0 => ({runApp: x0}),
      _324: x0 => new Uint8Array(x0),
      _326: x0 => x0.preventDefault(),
      _327: x0 => x0.stopPropagation(),
      _328: (x0,x1) => x0.addListener(x1),
      _329: (x0,x1) => x0.removeListener(x1),
      _330: (x0,x1) => x0.prepend(x1),
      _331: x0 => x0.remove(),
      _332: x0 => x0.disconnect(),
      _333: (x0,x1) => x0.addListener(x1),
      _334: (x0,x1) => x0.removeListener(x1),
      _335: x0 => x0.blur(),
      _336: (x0,x1) => x0.append(x1),
      _337: x0 => x0.remove(),
      _338: x0 => x0.stopPropagation(),
      _342: x0 => x0.preventDefault(),
      _343: (x0,x1) => x0.append(x1),
      _344: x0 => x0.remove(),
      _345: x0 => x0.preventDefault(),
      _350: (x0,x1) => x0.removeChild(x1),
      _351: (x0,x1) => x0.appendChild(x1),
      _352: (x0,x1,x2) => x0.insertBefore(x1,x2),
      _353: (x0,x1) => x0.appendChild(x1),
      _354: (x0,x1) => x0.transferFromImageBitmap(x1),
      _356: (x0,x1) => x0.append(x1),
      _357: (x0,x1) => x0.append(x1),
      _358: (x0,x1) => x0.append(x1),
      _359: x0 => x0.remove(),
      _360: x0 => x0.remove(),
      _361: x0 => x0.remove(),
      _362: (x0,x1) => x0.appendChild(x1),
      _363: (x0,x1) => x0.appendChild(x1),
      _364: x0 => x0.remove(),
      _365: (x0,x1) => x0.append(x1),
      _366: (x0,x1) => x0.append(x1),
      _367: x0 => x0.remove(),
      _368: (x0,x1) => x0.append(x1),
      _369: (x0,x1) => x0.append(x1),
      _370: (x0,x1,x2) => x0.insertBefore(x1,x2),
      _371: (x0,x1) => x0.append(x1),
      _372: (x0,x1,x2) => x0.insertBefore(x1,x2),
      _373: x0 => x0.remove(),
      _374: (x0,x1) => x0.append(x1),
      _375: x0 => x0.remove(),
      _376: (x0,x1) => x0.append(x1),
      _377: x0 => x0.remove(),
      _378: x0 => x0.remove(),
      _379: x0 => x0.getBoundingClientRect(),
      _380: x0 => x0.remove(),
      _393: (x0,x1) => x0.append(x1),
      _394: x0 => x0.remove(),
      _395: (x0,x1) => x0.append(x1),
      _396: (x0,x1,x2) => x0.insertBefore(x1,x2),
      _397: x0 => x0.preventDefault(),
      _398: x0 => x0.preventDefault(),
      _399: x0 => x0.preventDefault(),
      _400: x0 => x0.preventDefault(),
      _401: (x0,x1) => x0.observe(x1),
      _402: x0 => x0.disconnect(),
      _403: (x0,x1) => x0.appendChild(x1),
      _404: (x0,x1) => x0.appendChild(x1),
      _405: (x0,x1) => x0.appendChild(x1),
      _406: (x0,x1) => x0.append(x1),
      _407: x0 => x0.remove(),
      _408: (x0,x1) => x0.append(x1),
      _410: (x0,x1) => x0.appendChild(x1),
      _411: (x0,x1) => x0.append(x1),
      _412: x0 => x0.remove(),
      _413: (x0,x1) => x0.append(x1),
      _414: x0 => x0.remove(),
      _418: (x0,x1) => x0.appendChild(x1),
      _419: x0 => x0.remove(),
      _978: () => globalThis.window.flutterConfiguration,
      _979: x0 => x0.assetBase,
      _984: x0 => x0.debugShowSemanticsNodes,
      _985: x0 => x0.hostElement,
      _986: x0 => x0.multiViewEnabled,
      _987: x0 => x0.nonce,
      _989: x0 => x0.fontFallbackBaseUrl,
      _995: x0 => x0.console,
      _996: x0 => x0.devicePixelRatio,
      _997: x0 => x0.document,
      _998: x0 => x0.history,
      _999: x0 => x0.innerHeight,
      _1000: x0 => x0.innerWidth,
      _1001: x0 => x0.location,
      _1002: x0 => x0.navigator,
      _1003: x0 => x0.visualViewport,
      _1004: x0 => x0.performance,
      _1007: (x0,x1) => x0.dispatchEvent(x1),
      _1008: (x0,x1) => x0.matchMedia(x1),
      _1010: (x0,x1) => x0.getComputedStyle(x1),
      _1011: x0 => x0.screen,
      _1012: (x0,x1) => x0.requestAnimationFrame(x1),
      _1013: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1013(f,arguments.length,x0) }),
      _1018: (x0,x1) => x0.warn(x1),
      _1021: () => globalThis.window,
      _1022: () => globalThis.Intl,
      _1023: () => globalThis.Symbol,
      _1026: x0 => x0.clipboard,
      _1027: x0 => x0.maxTouchPoints,
      _1028: x0 => x0.vendor,
      _1029: x0 => x0.language,
      _1030: x0 => x0.platform,
      _1031: x0 => x0.userAgent,
      _1032: x0 => x0.languages,
      _1033: x0 => x0.documentElement,
      _1034: (x0,x1) => x0.querySelector(x1),
      _1038: (x0,x1) => x0.createElement(x1),
      _1039: (x0,x1) => x0.execCommand(x1),
      _1042: (x0,x1) => x0.createTextNode(x1),
      _1043: (x0,x1) => x0.createEvent(x1),
      _1047: x0 => x0.head,
      _1048: x0 => x0.body,
      _1049: (x0,x1) => x0.title = x1,
      _1052: x0 => x0.activeElement,
      _1054: x0 => x0.visibilityState,
      _1056: x0 => x0.hasFocus(),
      _1057: () => globalThis.document,
      _1058: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      _1059: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      _1062: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1062(f,arguments.length,x0) }),
      _1063: x0 => x0.target,
      _1065: x0 => x0.timeStamp,
      _1066: x0 => x0.type,
      _1068: x0 => x0.preventDefault(),
      _1070: (x0,x1,x2,x3) => x0.initEvent(x1,x2,x3),
      _1077: x0 => x0.firstChild,
      _1082: x0 => x0.parentElement,
      _1084: x0 => x0.parentNode,
      _1088: (x0,x1) => x0.removeChild(x1),
      _1089: (x0,x1) => x0.removeChild(x1),
      _1090: x0 => x0.isConnected,
      _1091: (x0,x1) => x0.textContent = x1,
      _1095: (x0,x1) => x0.contains(x1),
      _1101: x0 => x0.firstElementChild,
      _1103: x0 => x0.nextElementSibling,
      _1104: x0 => x0.clientHeight,
      _1105: x0 => x0.clientWidth,
      _1106: x0 => x0.offsetHeight,
      _1107: x0 => x0.offsetWidth,
      _1108: x0 => x0.id,
      _1109: (x0,x1) => x0.id = x1,
      _1112: (x0,x1) => x0.spellcheck = x1,
      _1113: x0 => x0.tagName,
      _1114: x0 => x0.style,
      _1115: (x0,x1) => x0.append(x1),
      _1117: (x0,x1) => x0.getAttribute(x1),
      _1118: x0 => x0.getBoundingClientRect(),
      _1121: (x0,x1) => x0.closest(x1),
      _1124: (x0,x1) => x0.querySelectorAll(x1),
      _1126: x0 => x0.remove(),
      _1127: (x0,x1,x2) => x0.setAttribute(x1,x2),
      _1128: (x0,x1) => x0.removeAttribute(x1),
      _1129: (x0,x1) => x0.tabIndex = x1,
      _1132: (x0,x1) => x0.focus(x1),
      _1133: x0 => x0.scrollTop,
      _1134: (x0,x1) => x0.scrollTop = x1,
      _1135: x0 => x0.scrollLeft,
      _1136: (x0,x1) => x0.scrollLeft = x1,
      _1137: x0 => x0.classList,
      _1138: (x0,x1) => x0.className = x1,
      _1144: (x0,x1) => x0.getElementsByClassName(x1),
      _1146: x0 => x0.click(),
      _1147: (x0,x1) => x0.hasAttribute(x1),
      _1150: (x0,x1) => x0.attachShadow(x1),
      _1155: (x0,x1) => x0.getPropertyValue(x1),
      _1157: (x0,x1,x2,x3) => x0.setProperty(x1,x2,x3),
      _1159: (x0,x1) => x0.removeProperty(x1),
      _1161: x0 => x0.offsetLeft,
      _1162: x0 => x0.offsetTop,
      _1163: x0 => x0.offsetParent,
      _1165: (x0,x1) => x0.name = x1,
      _1166: x0 => x0.content,
      _1167: (x0,x1) => x0.content = x1,
      _1185: (x0,x1) => x0.nonce = x1,
      _1191: x0 => x0.now(),
      _1193: (x0,x1) => x0.width = x1,
      _1195: (x0,x1) => x0.height = x1,
      _1199: (x0,x1) => x0.getContext(x1),
      _1270: x0 => x0.width,
      _1271: x0 => x0.height,
      _1275: (x0,x1) => x0.fetch(x1),
      _1276: x0 => x0.status,
      _1278: x0 => x0.body,
      _1279: x0 => x0.arrayBuffer(),
      _1285: x0 => x0.read(),
      _1286: x0 => x0.value,
      _1287: x0 => x0.done,
      _1289: x0 => x0.name,
      _1290: x0 => x0.x,
      _1291: x0 => x0.y,
      _1294: x0 => x0.top,
      _1295: x0 => x0.right,
      _1296: x0 => x0.bottom,
      _1297: x0 => x0.left,
      _1306: x0 => x0.height,
      _1307: x0 => x0.width,
      _1308: (x0,x1) => x0.value = x1,
      _1310: (x0,x1) => x0.placeholder = x1,
      _1311: (x0,x1) => x0.name = x1,
      _1312: x0 => x0.selectionDirection,
      _1313: x0 => x0.selectionStart,
      _1314: x0 => x0.selectionEnd,
      _1317: x0 => x0.value,
      _1319: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
      _1322: x0 => x0.readText(),
      _1323: (x0,x1) => x0.writeText(x1),
      _1324: x0 => x0.altKey,
      _1325: x0 => x0.code,
      _1326: x0 => x0.ctrlKey,
      _1327: x0 => x0.key,
      _1328: x0 => x0.keyCode,
      _1329: x0 => x0.location,
      _1330: x0 => x0.metaKey,
      _1331: x0 => x0.repeat,
      _1332: x0 => x0.shiftKey,
      _1333: x0 => x0.isComposing,
      _1334: (x0,x1) => x0.getModifierState(x1),
      _1336: x0 => x0.state,
      _1337: (x0,x1) => x0.go(x1),
      _1339: (x0,x1,x2,x3) => x0.pushState(x1,x2,x3),
      _1341: (x0,x1,x2,x3) => x0.replaceState(x1,x2,x3),
      _1342: x0 => x0.pathname,
      _1343: x0 => x0.search,
      _1344: x0 => x0.hash,
      _1348: x0 => x0.state,
      _1356: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1356(f,arguments.length,x0,x1) }),
      _1358: (x0,x1,x2) => x0.observe(x1,x2),
      _1361: x0 => x0.attributeName,
      _1362: x0 => x0.type,
      _1363: x0 => x0.matches,
      _1366: x0 => x0.matches,
      _1368: x0 => x0.relatedTarget,
      _1369: x0 => x0.clientX,
      _1370: x0 => x0.clientY,
      _1371: x0 => x0.offsetX,
      _1372: x0 => x0.offsetY,
      _1375: x0 => x0.button,
      _1376: x0 => x0.buttons,
      _1377: x0 => x0.ctrlKey,
      _1378: (x0,x1) => x0.getModifierState(x1),
      _1381: x0 => x0.pointerId,
      _1382: x0 => x0.pointerType,
      _1383: x0 => x0.pressure,
      _1384: x0 => x0.tiltX,
      _1385: x0 => x0.tiltY,
      _1386: x0 => x0.getCoalescedEvents(),
      _1388: x0 => x0.deltaX,
      _1389: x0 => x0.deltaY,
      _1390: x0 => x0.wheelDeltaX,
      _1391: x0 => x0.wheelDeltaY,
      _1392: x0 => x0.deltaMode,
      _1398: x0 => x0.changedTouches,
      _1400: x0 => x0.clientX,
      _1401: x0 => x0.clientY,
      _1403: x0 => x0.data,
      _1406: (x0,x1) => x0.disabled = x1,
      _1407: (x0,x1) => x0.type = x1,
      _1408: (x0,x1) => x0.max = x1,
      _1409: (x0,x1) => x0.min = x1,
      _1410: (x0,x1) => x0.value = x1,
      _1411: x0 => x0.value,
      _1412: x0 => x0.disabled,
      _1413: (x0,x1) => x0.disabled = x1,
      _1414: (x0,x1) => x0.placeholder = x1,
      _1415: (x0,x1) => x0.name = x1,
      _1416: (x0,x1) => x0.autocomplete = x1,
      _1417: x0 => x0.selectionDirection,
      _1418: x0 => x0.selectionStart,
      _1419: x0 => x0.selectionEnd,
      _1423: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
      _1428: (x0,x1) => x0.add(x1),
      _1432: (x0,x1) => x0.noValidate = x1,
      _1433: (x0,x1) => x0.method = x1,
      _1434: (x0,x1) => x0.action = x1,
      _1440: (x0,x1) => x0.getContext(x1),
      _1442: x0 => x0.convertToBlob(),
      _1459: x0 => x0.orientation,
      _1460: x0 => x0.width,
      _1461: x0 => x0.height,
      _1462: (x0,x1) => x0.lock(x1),
      _1478: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1478(f,arguments.length,x0,x1) }),
      _1489: x0 => x0.length,
      _1491: (x0,x1) => x0.item(x1),
      _1492: x0 => x0.length,
      _1493: (x0,x1) => x0.item(x1),
      _1494: x0 => x0.iterator,
      _1495: x0 => x0.Segmenter,
      _1496: x0 => x0.v8BreakIterator,
      _1499: x0 => x0.done,
      _1500: x0 => x0.value,
      _1501: x0 => x0.index,
      _1505: (x0,x1) => x0.adoptText(x1),
      _1506: x0 => x0.first(),
      _1507: x0 => x0.next(),
      _1508: x0 => x0.current(),
      _1522: x0 => x0.hostElement,
      _1523: x0 => x0.viewConstraints,
      _1525: x0 => x0.maxHeight,
      _1526: x0 => x0.maxWidth,
      _1527: x0 => x0.minHeight,
      _1528: x0 => x0.minWidth,
      _1529: x0 => x0.loader,
      _1530: () => globalThis._flutter,
      _1531: (x0,x1) => x0.didCreateEngineInitializer(x1),
      _1532: (x0,x1,x2) => x0.call(x1,x2),
      _1533: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1533(f,arguments.length,x0,x1) }),
      _1534: x0 => new Promise(x0),
      _1537: x0 => x0.length,
      _1540: x0 => x0.tracks,
      _1544: x0 => x0.image,
      _1551: x0 => x0.displayWidth,
      _1552: x0 => x0.displayHeight,
      _1553: x0 => x0.duration,
      _1556: x0 => x0.ready,
      _1557: x0 => x0.selectedTrack,
      _1558: x0 => x0.repetitionCount,
      _1559: x0 => x0.frameCount,
      _1604: (x0,x1) => x0.register = x1,
      _1605: (x0,x1) => x0.detail(x1),
      _1606: x0 => x0.detail,
      _1607: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1607(f,arguments.length,x0) }),
      _1608: (x0,x1,x2) => ({bubbles: x0,cancelable: x1,detail: x2}),
      _1609: (x0,x1) => new CustomEvent(x0,x1),
      _1610: (x0,x1) => x0.dispatchEvent(x1),
      _1611: (x0,x1) => new CustomEvent(x0,x1),
      _1612: (x0,x1) => x0.dispatchEvent(x1),
      _1641: x0 => new Array(x0),
      _1643: x0 => x0.length,
      _1645: (x0,x1) => x0[x1],
      _1646: (x0,x1,x2) => x0[x1] = x2,
      _1649: (x0,x1,x2) => new DataView(x0,x1,x2),
      _1651: x0 => new Int8Array(x0),
      _1652: (x0,x1,x2) => new Uint8Array(x0,x1,x2),
      _1653: x0 => new Uint8Array(x0),
      _1659: x0 => new Uint16Array(x0),
      _1661: x0 => new Int32Array(x0),
      _1663: x0 => new Uint32Array(x0),
      _1665: x0 => new Float32Array(x0),
      _1667: x0 => new Float64Array(x0),
      _1669: (o, c) => o instanceof c,
      _1673: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1673(f,arguments.length,x0) }),
      _1674: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1674(f,arguments.length,x0) }),
      _1676: (x0,x1) => x0.call(x1),
      _1699: (decoder, codeUnits) => decoder.decode(codeUnits),
      _1700: () => new TextDecoder("utf-8", {fatal: true}),
      _1701: () => new TextDecoder("utf-8", {fatal: false}),
      _1702: x0 => new WeakRef(x0),
      _1703: x0 => x0.deref(),
      _1709: Date.now,
      _1711: s => new Date(s * 1000).getTimezoneOffset() * 60,
      _1712: s => {
        if (!/^\s*[+-]?(?:Infinity|NaN|(?:\.\d+|\d+(?:\.\d*)?)(?:[eE][+-]?\d+)?)\s*$/.test(s)) {
          return NaN;
        }
        return parseFloat(s);
      },
      _1713: () => {
        let stackString = new Error().stack.toString();
        let frames = stackString.split('\n');
        let drop = 2;
        if (frames[0] === 'Error') {
            drop += 1;
        }
        return frames.slice(drop).join('\n');
      },
      _1714: () => typeof dartUseDateNowForTicks !== "undefined",
      _1715: () => 1000 * performance.now(),
      _1716: () => Date.now(),
      _1719: () => new WeakMap(),
      _1720: (map, o) => map.get(o),
      _1721: (map, o, v) => map.set(o, v),
      _1722: () => globalThis.WeakRef,
      _1733: s => JSON.stringify(s),
      _1734: s => printToConsole(s),
      _1735: a => a.join(''),
      _1736: (o, a, b) => o.replace(a, b),
      _1738: (s, t) => s.split(t),
      _1739: s => s.toLowerCase(),
      _1740: s => s.toUpperCase(),
      _1741: s => s.trim(),
      _1742: s => s.trimLeft(),
      _1743: s => s.trimRight(),
      _1744: (s, n) => s.repeat(n),
      _1745: (s, p, i) => s.indexOf(p, i),
      _1746: (s, p, i) => s.lastIndexOf(p, i),
      _1747: (s) => s.replace(/\$/g, "$$$$"),
      _1748: Object.is,
      _1749: s => s.toUpperCase(),
      _1750: s => s.toLowerCase(),
      _1751: (a, i) => a.push(i),
      _1752: (a, i) => a.splice(i, 1)[0],
      _1755: a => a.pop(),
      _1756: (a, i) => a.splice(i, 1),
      _1758: (a, s) => a.join(s),
      _1759: (a, s, e) => a.slice(s, e),
      _1762: a => a.length,
      _1764: (a, i) => a[i],
      _1765: (a, i, v) => a[i] = v,
      _1767: (o, offsetInBytes, lengthInBytes) => {
        var dst = new ArrayBuffer(lengthInBytes);
        new Uint8Array(dst).set(new Uint8Array(o, offsetInBytes, lengthInBytes));
        return new DataView(dst);
      },
      _1768: (o, start, length) => new Uint8Array(o.buffer, o.byteOffset + start, length),
      _1769: (o, start, length) => new Int8Array(o.buffer, o.byteOffset + start, length),
      _1770: (o, start, length) => new Uint8ClampedArray(o.buffer, o.byteOffset + start, length),
      _1771: (o, start, length) => new Uint16Array(o.buffer, o.byteOffset + start, length),
      _1772: (o, start, length) => new Int16Array(o.buffer, o.byteOffset + start, length),
      _1773: (o, start, length) => new Uint32Array(o.buffer, o.byteOffset + start, length),
      _1774: (o, start, length) => new Int32Array(o.buffer, o.byteOffset + start, length),
      _1776: (o, start, length) => new BigInt64Array(o.buffer, o.byteOffset + start, length),
      _1777: (o, start, length) => new Float32Array(o.buffer, o.byteOffset + start, length),
      _1778: (o, start, length) => new Float64Array(o.buffer, o.byteOffset + start, length),
      _1779: (t, s) => t.set(s),
      _1780: l => new DataView(new ArrayBuffer(l)),
      _1781: (o) => new DataView(o.buffer, o.byteOffset, o.byteLength),
      _1783: o => o.buffer,
      _1784: o => o.byteOffset,
      _1785: Function.prototype.call.bind(Object.getOwnPropertyDescriptor(DataView.prototype, 'byteLength').get),
      _1786: (b, o) => new DataView(b, o),
      _1787: (b, o, l) => new DataView(b, o, l),
      _1788: Function.prototype.call.bind(DataView.prototype.getUint8),
      _1789: Function.prototype.call.bind(DataView.prototype.setUint8),
      _1790: Function.prototype.call.bind(DataView.prototype.getInt8),
      _1791: Function.prototype.call.bind(DataView.prototype.setInt8),
      _1792: Function.prototype.call.bind(DataView.prototype.getUint16),
      _1793: Function.prototype.call.bind(DataView.prototype.setUint16),
      _1794: Function.prototype.call.bind(DataView.prototype.getInt16),
      _1795: Function.prototype.call.bind(DataView.prototype.setInt16),
      _1796: Function.prototype.call.bind(DataView.prototype.getUint32),
      _1797: Function.prototype.call.bind(DataView.prototype.setUint32),
      _1798: Function.prototype.call.bind(DataView.prototype.getInt32),
      _1799: Function.prototype.call.bind(DataView.prototype.setInt32),
      _1802: Function.prototype.call.bind(DataView.prototype.getBigInt64),
      _1803: Function.prototype.call.bind(DataView.prototype.setBigInt64),
      _1804: Function.prototype.call.bind(DataView.prototype.getFloat32),
      _1805: Function.prototype.call.bind(DataView.prototype.setFloat32),
      _1806: Function.prototype.call.bind(DataView.prototype.getFloat64),
      _1807: Function.prototype.call.bind(DataView.prototype.setFloat64),
      _1811: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1811(f,arguments.length,x0) }),
      _1812: (x0,x1,x2) => x0.on(x1,x2),
      _1813: x0 => x0.connect(),
      _1814: (x0,x1,x2,x3,x4,x5,x6,x7,x8,x9) => ({gasLimit: x0,maxPriorityFeePerGas: x1,maxFeePerGas: x2,gasPrice: x3,from: x4,to: x5,value: x6,data: x7,chainId: x8,type: x9}),
      _1815: (x0,x1) => ({account: x0,transaction: x1}),
      _1816: (x0,x1) => x0.sendTransaction(x1),
      _1817: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1817(f,arguments.length,x0) }),
      _1818: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1818(f,arguments.length,x0) }),
      _1819: x0 => ({method: x0}),
      _1820: (x0,x1) => x0.request(x1),
      _1821: (x0,x1) => x0.request(x1),
      _1822: (x0,x1) => x0.request(x1),
      _1823: (x0,x1) => ({method: x0,params: x1}),
      _1824: (x0,x1) => x0.request(x1),
      _1825: (x0,x1,x2) => x0.on(x1,x2),
      _1826: (x0,x1,x2) => x0.on(x1,x2),
      _1827: (x0,x1,x2) => x0.removeListener(x1,x2),
      _1828: (x0,x1,x2) => x0.removeListener(x1,x2),
      _1829: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1829(f,arguments.length,x0) }),
      _1830: (x0,x1,x2) => x0.on(x1,x2),
      _1831: x0 => x0.connect(),
      _1832: (x0,x1) => ({account: x0,transaction: x1}),
      _1833: (x0,x1) => x0.signTransaction(x1),
      _1834: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1834(f,arguments.length,x0) }),
      _1835: (x0,x1,x2) => x0.on(x1,x2),
      _1836: x0 => x0.connect(),
      _1837: (x0,x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12,x13,x14,x15) => ({address: x0,assetId: x1,blockHash: x2,blockNumber: x3,era: x4,genesisHash: x5,metadataHash: x6,method: x7,mode: x8,nonce: x9,specVersion: x10,tip: x11,transactionVersion: x12,signedExtensions: x13,version: x14,withSignedTransaction: x15}),
      _1838: (x0,x1) => x0.signTransaction(x1),
      _1839: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1839(f,arguments.length,x0) }),
      _1840: (x0,x1,x2) => x0.on(x1,x2),
      _1841: x0 => x0.connect(),
      _1842: (x0,x1) => ({transaction: x0,account: x1}),
      _1843: (x0,x1) => x0.signTransaction(x1),
      _1844: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1844(f,arguments.length,x0) }),
      _1845: (x0,x1,x2) => x0.on(x1,x2),
      _1846: x0 => x0.connect(),
      _1847: (x0,x1) => ({accounts: x0,psbt: x1}),
      _1848: (x0,x1) => x0.signTransaction(x1),
      _1849: (x0,x1,x2) => x0.close(x1,x2),
      _1862: (o, t) => o instanceof t,
      _1864: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1864(f,arguments.length,x0) }),
      _1865: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1865(f,arguments.length,x0) }),
      _1866: o => Object.keys(o),
      _1867: (ms, c) =>
      setTimeout(() => dartInstance.exports.$invokeCallback(c),ms),
      _1868: (handle) => clearTimeout(handle),
      _1869: (ms, c) =>
      setInterval(() => dartInstance.exports.$invokeCallback(c), ms),
      _1870: (handle) => clearInterval(handle),
      _1871: (c) =>
      queueMicrotask(() => dartInstance.exports.$invokeCallback(c)),
      _1872: () => Date.now(),
      _1891: (x0,x1,x2,x3,x4,x5) => ({method: x0,headers: x1,body: x2,credentials: x3,redirect: x4,signal: x5}),
      _1892: (x0,x1,x2) => x0.fetch(x1,x2),
      _1893: (x0,x1) => x0.get(x1),
      _1894: f => finalizeWrapper(f, function(x0,x1,x2) { return dartInstance.exports._1894(f,arguments.length,x0,x1,x2) }),
      _1895: (x0,x1) => x0.forEach(x1),
      _1896: x0 => x0.abort(),
      _1897: () => new AbortController(),
      _1898: x0 => x0.getReader(),
      _1899: x0 => x0.read(),
      _1900: x0 => x0.cancel(),
      _1904: x0 => x0.supportedTransactionVersions,
      _1905: x0 => x0.signTransaction,
      _1906: x0 => x0.signedTransaction,
      _1913: x0 => x0.accounts,
      _1914: x0 => x0.address,
      _1916: x0 => x0.chains,
      _1922: x0 => x0.witnessScript,
      _1923: x0 => x0.redeemScript,
      _1924: x0 => x0.publicKey,
      _1926: x0 => x0.algo,
      _1927: x0 => x0.publicKey,
      _1930: x0 => x0.on,
      _1932: x0 => x0.accounts,
      _1933: x0 => x0.standard:connect,
      _1935: x0 => x0.standard:events,
      _1937: x0 => x0.substrate:signTransaction,
      _1939: x0 => x0.solana:signTransaction,
      _1940: x0 => x0.ethereum:sendTransaction,
      _1942: x0 => x0.cosmos:signTransaction,
      _1944: x0 => x0.bitcoin:signTransaction,
      _1946: x0 => x0.chains,
      _1947: x0 => x0.features,
      _1948: x0 => x0.accounts,
      _1949: x0 => x0.name,
      _1950: x0 => x0.icon,
      _1951: x0 => x0.isMRT,
      _1957: x0 => x0.signTransaction,
      _1962: x0 => x0.bodyBytes,
      _1964: x0 => x0.authInfoBytes,
      _1970: x0 => x0.signed,
      _1972: x0 => x0.signature,
      _1977: x0 => x0.signature,
      _1981: x0 => x0.signTransaction,
      _1982: x0 => x0.psbt,
      _1983: () => globalThis.ethereum,
      _1989: x0 => x0.message,
      _1991: x0 => x0.selectedAddress,
      _1992: x0 => x0.name,
      _1993: x0 => x0.icon,
      _1994: x0 => x0.request,
      _1995: x0 => x0.on,
      _1997: x0 => x0.removeListener,
      _2000: x0 => x0.name,
      _2001: x0 => x0.icon,
      _2003: x0 => x0.info,
      _2004: x0 => x0.provider,
      _2038: x0 => x0.sendTransaction,
      _2039: x0 => x0.txId,
      _2157: x0 => x0.storage,
      _2159: x0 => x0.runtime,
      _2163: x0 => x0.runtime,
      _2166: () => globalThis.chrome,
      _2167: () => globalThis.chrome,
      _2168: () => globalThis.browser,
      _2169: () => globalThis.browser,
      _2170: (x0,x1) => x0.getItem(x1),
      _2171: (x0,x1) => x0.getItem(x1),
      _2172: (x0,x1,x2) => x0.setItem(x1,x2),
      _2173: x0 => x0.clear(),
      _2174: (x0,x1,x2) => x0.setItem(x1,x2),
      _2175: (x0,x1,x2) => x0.setItem(x1,x2),
      _2177: (x0,x1) => x0.getItem(x1),
      _2179: (x0,x1,x2) => x0.setItem(x1,x2),
      _2183: (x0,x1,x2,x3) => x0.open(x1,x2,x3),
      _2184: () => globalThis.localStorage,
      _2191: x0 => globalThis.Object.entries(x0),
      _2209: (x0,x1) => x0.getURL(x1),
      _2211: x0 => x0.id,
      _2247: () => globalThis.window,
      _2249: x0 => x0.BarcodeDetector,
      _2251: x0 => x0.navigator,
      _2253: x0 => x0.document,
      _2256: (x0,x1) => x0.fetch(x1),
      _2259: x0 => x0.focus(),
      _2272: (x0,x1) => x0.createElement(x1),
      _2273: x0 => x0.body,
      _2275: x0 => x0.hasFocus(),
      _2276: x0 => globalThis.URL.createObjectURL(x0),
      _2277: (x0,x1) => x0.appendChild(x1),
      _2278: x0 => x0.click(),
      _2279: (x0,x1) => x0.removeChild(x1),
      _2283: (x0,x1) => x0.writeText(x1),
      _2285: x0 => x0.readText(),
      _2290: x0 => x0.clipboard,
      _2311: (x0,x1) => new Blob(x0,x1),
      _2316: x0 => x0.ok,
      _2318: x0 => x0.arrayBuffer(),
      _2319: x0 => x0.text(),
      _2348: x0 => x0.data,
      _2350: (x0,x1,x2) => x0.addEventListener(x1,x2),
      _2352: (x0,x1,x2) => x0.removeEventListener(x1,x2),
      _2354: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._2354(f,arguments.length,x0) }),
      _2356: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._2356(f,arguments.length,x0) }),
      _2378: (x0,x1) => new WebSocket(x0,x1),
      _2379: x0 => x0.readyState,
      _2381: (x0,x1) => x0.send(x1),
      _2383: x0 => x0.local,
      _2392: (x0,x1) => x0.get(x1),
      _2404: (x0,x1) => x0.set(x1),
      _2423: (s, m) => {
        try {
          return new RegExp(s, m);
        } catch (e) {
          return String(e);
        }
      },
      _2424: (x0,x1) => x0.exec(x1),
      _2425: (x0,x1) => x0.test(x1),
      _2426: (x0,x1) => x0.exec(x1),
      _2427: (x0,x1) => x0.exec(x1),
      _2428: x0 => x0.pop(),
      _2430: o => o === undefined,
      _2449: o => typeof o === 'function' && o[jsWrappedDartFunctionSymbol] === true,
      _2451: o => {
        const proto = Object.getPrototypeOf(o);
        return proto === Object.prototype || proto === null;
      },
      _2452: o => o instanceof RegExp,
      _2453: (l, r) => l === r,
      _2454: o => o,
      _2455: o => o,
      _2456: o => o,
      _2457: b => !!b,
      _2458: o => o.length,
      _2461: (o, i) => o[i],
      _2462: f => f.dartFunction,
      _2463: l => arrayFromDartList(Int8Array, l),
      _2464: l => arrayFromDartList(Uint8Array, l),
      _2465: l => arrayFromDartList(Uint8ClampedArray, l),
      _2466: l => arrayFromDartList(Int16Array, l),
      _2467: l => arrayFromDartList(Uint16Array, l),
      _2468: l => arrayFromDartList(Int32Array, l),
      _2469: l => arrayFromDartList(Uint32Array, l),
      _2470: l => arrayFromDartList(Float32Array, l),
      _2471: l => arrayFromDartList(Float64Array, l),
      _2472: x0 => new ArrayBuffer(x0),
      _2473: (data, length) => {
        const getValue = dartInstance.exports.$byteDataGetUint8;
        const view = new DataView(new ArrayBuffer(length));
        for (let i = 0; i < length; i++) {
          view.setUint8(i, getValue(data, i));
        }
        return view;
      },
      _2474: l => arrayFromDartList(Array, l),
      _2475: () => ({}),
      _2476: () => [],
      _2477: l => new Array(l),
      _2478: () => globalThis,
      _2479: (constructor, args) => {
        const factoryFunction = constructor.bind.apply(
            constructor, [null, ...args]);
        return new factoryFunction();
      },
      _2480: (o, p) => p in o,
      _2481: (o, p) => o[p],
      _2482: (o, p, v) => o[p] = v,
      _2483: (o, m, a) => o[m].apply(o, a),
      _2485: o => String(o),
      _2486: (p, s, f) => p.then(s, f),
      _2487: o => {
        if (o === undefined) return 1;
        var type = typeof o;
        if (type === 'boolean') return 2;
        if (type === 'number') return 3;
        if (type === 'string') return 4;
        if (o instanceof Array) return 5;
        if (ArrayBuffer.isView(o)) {
          if (o instanceof Int8Array) return 6;
          if (o instanceof Uint8Array) return 7;
          if (o instanceof Uint8ClampedArray) return 8;
          if (o instanceof Int16Array) return 9;
          if (o instanceof Uint16Array) return 10;
          if (o instanceof Int32Array) return 11;
          if (o instanceof Uint32Array) return 12;
          if (o instanceof Float32Array) return 13;
          if (o instanceof Float64Array) return 14;
          if (o instanceof DataView) return 15;
        }
        if (o instanceof ArrayBuffer) return 16;
        return 17;
      },
      _2488: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI8ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _2489: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI8ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _2490: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI16ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _2491: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI16ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _2492: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _2493: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI32ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _2494: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _2495: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmF32ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _2496: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF64ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _2497: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmF64ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _2498: s => {
        if (/[[\]{}()*+?.\\^$|]/.test(s)) {
            s = s.replace(/[[\]{}()*+?.\\^$|]/g, '\\$&');
        }
        return s;
      },
      _2501: x0 => x0.index,
      _2504: (x0,x1) => x0.exec(x1),
      _2506: x0 => x0.flags,
      _2507: x0 => x0.multiline,
      _2508: x0 => x0.ignoreCase,
      _2509: x0 => x0.unicode,
      _2510: x0 => x0.dotAll,
      _2511: (x0,x1) => x0.lastIndex = x1,
      _2513: (o, p) => o[p],
      _2516: x0 => x0.random(),
      _2517: x0 => x0.random(),
      _2518: (x0,x1) => x0.getRandomValues(x1),
      _2519: () => globalThis.crypto,
      _2521: () => globalThis.Math,
      _2523: Function.prototype.call.bind(Number.prototype.toString),
      _2524: (d, digits) => d.toFixed(digits),
      _4398: () => globalThis.window,
      _7101: x0 => x0.signal,
      _9005: x0 => x0.value,
      _9007: x0 => x0.done,
      _9730: x0 => x0.url,
      _9732: x0 => x0.status,
      _9734: x0 => x0.statusText,
      _9735: x0 => x0.headers,
      _9736: x0 => x0.body,
      _14157: x0 => x0.signTransaction,
      _14159: x0 => x0.signature,
      _14160: x0 => globalThis.Uint8Array.from(x0),
      _14233: x0 => globalThis.Object.keys(x0),
      _14259: (x0,x1) => x0.href = x1,
      _14260: (x0,x1) => x0.target = x1,
      _14261: (x0,x1) => x0.download = x1,

    };

    const baseImports = {
      dart2wasm: dart2wasm,


      Math: Math,
      Date: Date,
      Object: Object,
      Array: Array,
      Reflect: Reflect,
    };

    const jsStringPolyfill = {
      "charCodeAt": (s, i) => s.charCodeAt(i),
      "compare": (s1, s2) => {
        if (s1 < s2) return -1;
        if (s1 > s2) return 1;
        return 0;
      },
      "concat": (s1, s2) => s1 + s2,
      "equals": (s1, s2) => s1 === s2,
      "fromCharCode": (i) => String.fromCharCode(i),
      "length": (s) => s.length,
      "substring": (s, a, b) => s.substring(a, b),
      "fromCharCodeArray": (a, start, end) => {
        if (end <= start) return '';

        const read = dartInstance.exports.$wasmI16ArrayGet;
        let result = '';
        let index = start;
        const chunkLength = Math.min(end - index, 500);
        let array = new Array(chunkLength);
        while (index < end) {
          const newChunkLength = Math.min(end - index, 500);
          for (let i = 0; i < newChunkLength; i++) {
            array[i] = read(a, index++);
          }
          if (newChunkLength < chunkLength) {
            array = array.slice(0, newChunkLength);
          }
          result += String.fromCharCode(...array);
        }
        return result;
      },
    };

    const deferredLibraryHelper = {
      "loadModule": async (moduleName) => {
        if (!loadDeferredWasm) {
          throw "No implementation of loadDeferredWasm provided.";
        }
        const source = await Promise.resolve(loadDeferredWasm(moduleName));
        const module = await ((source instanceof Response)
            ? WebAssembly.compileStreaming(source, this.builtins)
            : WebAssembly.compile(source, this.builtins));
        return await WebAssembly.instantiate(module, {
          ...baseImports,
          ...additionalImports,
          "wasm:js-string": jsStringPolyfill,
          "module0": dartInstance.exports,
        });
      },
    };

    dartInstance = await WebAssembly.instantiate(this.module, {
      ...baseImports,
      ...additionalImports,
      "deferredLibraryHelper": deferredLibraryHelper,
      "wasm:js-string": jsStringPolyfill,
    });

    return new InstantiatedApp(this, dartInstance);
  }
}

class InstantiatedApp {
  constructor(compiledApp, instantiatedModule) {
    this.compiledApp = compiledApp;
    this.instantiatedModule = instantiatedModule;
  }

  // Call the main function with the given arguments.
  invokeMain(...args) {
    this.instantiatedModule.exports.$invokeMain(args);
  }
}

