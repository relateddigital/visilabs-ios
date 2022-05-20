( function( global, factory ) {
	"use strict";

	if ( typeof module === "object" && typeof module.exports === "object" ) {
		module.exports = global.document ?
			factory( global, true ) :
			function( w ) {
				if ( !w.document ) {
					throw new Error( "jQuery requires a window with a document" );
				}
				return factory( w );
			};
	} else {
		factory( global );
	}
} )( typeof window !== "undefined" ? window : this, function( window, noGlobal ) {
"use strict";
var arr = [];
var getProto = Object.getPrototypeOf;
var slice = arr.slice;
var flat = arr.flat ? function( array ) {
	return arr.flat.call( array );
} : function( array ) {
	return arr.concat.apply( [], array );
};
var push = arr.push;

var indexOf = arr.indexOf;

var class2type = {};

var toString = class2type.toString;

var hasOwn = class2type.hasOwnProperty;

var fnToString = hasOwn.toString;

var ObjectFunctionString = fnToString.call( Object );

var support = {};

var isFunction = function isFunction( obj ) {
		return typeof obj === "function" && typeof obj.nodeType !== "number" &&
			typeof obj.item !== "function";
	};


var isWindow = function isWindow( obj ) {
		return obj != null && obj === obj.window;
	};

var document = window.document;
	var preservedScriptAttributes = {
		type: true,
		src: true,
		nonce: true,
		noModule: true
	};

	function DOMEval( code, node, doc ) {
		doc = doc || document;

		var i, val,
			script = doc.createElement( "script" );

		script.text = code;
		if ( node ) {
			for ( i in preservedScriptAttributes ) {
				val = node[ i ] || node.getAttribute && node.getAttribute( i );
				if ( val ) {
					script.setAttribute( i, val );
				}
			}
		}
		doc.head.appendChild( script ).parentNode.removeChild( script );
	}


function toType( obj ) {
	if ( obj == null ) {
		return obj + "";
	}
	return typeof obj === "object" || typeof obj === "function" ?
		class2type[ toString.call( obj ) ] || "object" :
		typeof obj;
}
var
	version = "3.6.0",

	jQuery = function( selector, context ) {
		return new jQuery.fn.init( selector, context );
	};

jQuery.fn = jQuery.prototype = {
	jquery: version,
	constructor: jQuery,

	length: 0,

	toArray: function() {
		return slice.call( this );
	},
	get: function( num ) {
		if ( num == null ) {
			return slice.call( this );
		}
		return num < 0 ? this[ num + this.length ] : this[ num ];
	},
	pushStack: function( elems ) {
		var ret = jQuery.merge( this.constructor(), elems );
		ret.prevObject = this;
		return ret;
	},
	each: function( callback ) {
		return jQuery.each( this, callback );
	},

	map: function( callback ) {
		return this.pushStack( jQuery.map( this, function( elem, i ) {
			return callback.call( elem, i, elem );
		} ) );
	},

	slice: function() {
		return this.pushStack( slice.apply( this, arguments ) );
	},

	first: function() {
		return this.eq( 0 );
	},

	last: function() {
		return this.eq( -1 );
	},

	even: function() {
		return this.pushStack( jQuery.grep( this, function( _elem, i ) {
			return ( i + 1 ) % 2;
		} ) );
	},

	odd: function() {
		return this.pushStack( jQuery.grep( this, function( _elem, i ) {
			return i % 2;
		} ) );
	},

	eq: function( i ) {
		var len = this.length,
			j = +i + ( i < 0 ? len : 0 );
		return this.pushStack( j >= 0 && j < len ? [ this[ j ] ] : [] );
	},

	end: function() {
		return this.prevObject || this.constructor();
	},
	push: push,
	sort: arr.sort,
	splice: arr.splice
};

jQuery.extend = jQuery.fn.extend = function() {
	var options, name, src, copy, copyIsArray, clone,
		target = arguments[ 0 ] || {},
		i = 1,
		length = arguments.length,
		deep = false;

	if ( typeof target === "boolean" ) {
		deep = target;

		target = arguments[ i ] || {};
		i++;
	}

	if ( typeof target !== "object" && !isFunction( target ) ) {
		target = {};
	}

	if ( i === length ) {
		target = this;
		i--;
	}

	for ( ; i < length; i++ ) {

		if ( ( options = arguments[ i ] ) != null ) {

			for ( name in options ) {
				copy = options[ name ];
				if ( name === "__proto__" || target === copy ) {
					continue;
				}

				if ( deep && copy && ( jQuery.isPlainObject( copy ) ||
					( copyIsArray = Array.isArray( copy ) ) ) ) {
					src = target[ name ];

					if ( copyIsArray && !Array.isArray( src ) ) {
						clone = [];
					} else if ( !copyIsArray && !jQuery.isPlainObject( src ) ) {
						clone = {};
					} else {
						clone = src;
					}
					copyIsArray = false;

					target[ name ] = jQuery.extend( deep, clone, copy );

				} else if ( copy !== undefined ) {
					target[ name ] = copy;
				}
			}
		}
	}
	return target;
};

jQuery.extend( {

	expando: "jQuery" + ( version + Math.random() ).replace( /\D/g, "" ),

	isReady: true,

	error: function( msg ) {
		throw new Error( msg );
	},

	noop: function() {},

	isPlainObject: function( obj ) {
		var proto, Ctor;
		if ( !obj || toString.call( obj ) !== "[object Object]" ) {
			return false;
		}

		proto = getProto( obj );

		if ( !proto ) {
			return true;
		}

		Ctor = hasOwn.call( proto, "constructor" ) && proto.constructor;
		return typeof Ctor === "function" && fnToString.call( Ctor ) === ObjectFunctionString;
	},

	isEmptyObject: function( obj ) {
		var name;

		for ( name in obj ) {
			return false;
		}
		return true;
	},


	globalEval: function( code, options, doc ) {
		DOMEval( code, { nonce: options && options.nonce }, doc );
	},

	each: function( obj, callback ) {
		var length, i = 0;

		if ( isArrayLike( obj ) ) {
			length = obj.length;
			for ( ; i < length; i++ ) {
				if ( callback.call( obj[ i ], i, obj[ i ] ) === false ) {
					break;
				}
			}
		} else {
			for ( i in obj ) {
				if ( callback.call( obj[ i ], i, obj[ i ] ) === false ) {
					break;
				}
			}
		}

		return obj;
	},

	makeArray: function( arr, results ) {
		var ret = results || [];

		if ( arr != null ) {
			if ( isArrayLike( Object( arr ) ) ) {
				jQuery.merge( ret,
					typeof arr === "string" ?
						[ arr ] : arr
				);
			} else {
				push.call( ret, arr );
			}
		}

		return ret;
	},

	inArray: function( elem, arr, i ) {
		return arr == null ? -1 : indexOf.call( arr, elem, i );
	},
	merge: function( first, second ) {
		var len = +second.length,
			j = 0,
			i = first.length;

		for ( ; j < len; j++ ) {
			first[ i++ ] = second[ j ];
		}

		first.length = i;

		return first;
	},

	grep: function( elems, callback, invert ) {
		var callbackInverse,
			matches = [],
			i = 0,
			length = elems.length,
			callbackExpect = !invert;
		for ( ; i < length; i++ ) {
			callbackInverse = !callback( elems[ i ], i );
			if ( callbackInverse !== callbackExpect ) {
				matches.push( elems[ i ] );
			}
		}

		return matches;
	},

	map: function( elems, callback, arg ) {
		var length, value,
			i = 0,
			ret = [];

		if ( isArrayLike( elems ) ) {
			length = elems.length;
			for ( ; i < length; i++ ) {
				value = callback( elems[ i ], i, arg );

				if ( value != null ) {
					ret.push( value );
				}
			}

		} else {
			for ( i in elems ) {
				value = callback( elems[ i ], i, arg );

				if ( value != null ) {
					ret.push( value );
				}
			}
		}

		return flat( ret );
	},

	guid: 1,
	support: support
} );

if ( typeof Symbol === "function" ) {
	jQuery.fn[ Symbol.iterator ] = arr[ Symbol.iterator ];
}

jQuery.each( "Boolean Number String Function Array Date RegExp Object Error Symbol".split( " " ),
	function( _i, name ) {
		class2type[ "[object " + name + "]" ] = name.toLowerCase();
	} );

function isArrayLike( obj ) {
	var length = !!obj && "length" in obj && obj.length,
		type = toType( obj );

	if ( isFunction( obj ) || isWindow( obj ) ) {
		return false;
	}

	return type === "array" || length === 0 ||
		typeof length === "number" && length > 0 && ( length - 1 ) in obj;
}
var Sizzle =

( function( window ) {
var i,
	support,
	Expr,
	getText,
	isXML,
	tokenize,
	compile,
	select,
	outermostContext,
	sortInput,
	hasDuplicate,

	// Local document vars
	setDocument,
	document,
	docElem,
	documentIsHTML,
	rbuggyQSA,
	rbuggyMatches,
	matches,
	contains,

	expando = "sizzle" + 1 * new Date(),
	preferredDoc = window.document,
	dirruns = 0,
	done = 0,
	classCache = createCache(),
	tokenCache = createCache(),
	compilerCache = createCache(),
	nonnativeSelectorCache = createCache(),
	sortOrder = function( a, b ) {
		if ( a === b ) {
			hasDuplicate = true;
		}
		return 0;
	},

	hasOwn = ( {} ).hasOwnProperty,
	arr = [],
	pop = arr.pop,
	pushNative = arr.push,
	push = arr.push,
	slice = arr.slice,

	indexOf = function( list, elem ) {
		var i = 0,
			len = list.length;
		for ( ; i < len; i++ ) {
			if ( list[ i ] === elem ) {
				return i;
			}
		}
		return -1;
	},

	booleans = "checked|selected|async|autofocus|autoplay|controls|defer|disabled|hidden|" +
		"ismap|loop|multiple|open|readonly|required|scoped",

	whitespace = "[\\x20\\t\\r\\n\\f]",

	identifier = "(?:\\\\[\\da-fA-F]{1,6}" + whitespace +
		"?|\\\\[^\\r\\n\\f]|[\\w-]|[^\0-\\x7f])+",

	attributes = "\\[" + whitespace + "*(" + identifier + ")(?:" + whitespace +

		"*([*^$|!~]?=)" + whitespace +

		"*(?:'((?:\\\\.|[^\\\\'])*)'|\"((?:\\\\.|[^\\\\\"])*)\"|(" + identifier + "))|)" +
		whitespace + "*\\]",

	pseudos = ":(" + identifier + ")(?:\\((" +

		"('((?:\\\\.|[^\\\\'])*)'|\"((?:\\\\.|[^\\\\\"])*)\")|" +

		"((?:\\\\.|[^\\\\()[\\]]|" + attributes + ")*)|" +

		".*" +
		")\\)|)",

	rwhitespace = new RegExp( whitespace + "+", "g" ),
	rtrim = new RegExp( "^" + whitespace + "+|((?:^|[^\\\\])(?:\\\\.)*)" +
		whitespace + "+$", "g" ),

	rcomma = new RegExp( "^" + whitespace + "*," + whitespace + "*" ),
	rcombinators = new RegExp( "^" + whitespace + "*([>+~]|" + whitespace + ")" + whitespace +
		"*" ),
	rdescend = new RegExp( whitespace + "|>" ),

	rpseudo = new RegExp( pseudos ),
	ridentifier = new RegExp( "^" + identifier + "$" ),

	matchExpr = {
		"ID": new RegExp( "^#(" + identifier + ")" ),
		"CLASS": new RegExp( "^\\.(" + identifier + ")" ),
		"TAG": new RegExp( "^(" + identifier + "|[*])" ),
		"ATTR": new RegExp( "^" + attributes ),
		"PSEUDO": new RegExp( "^" + pseudos ),
		"CHILD": new RegExp( "^:(only|first|last|nth|nth-last)-(child|of-type)(?:\\(" +
			whitespace + "*(even|odd|(([+-]|)(\\d*)n|)" + whitespace + "*(?:([+-]|)" +
			whitespace + "*(\\d+)|))" + whitespace + "*\\)|)", "i" ),
		"bool": new RegExp( "^(?:" + booleans + ")$", "i" ),
		"needsContext": new RegExp( "^" + whitespace +
			"*[>+~]|:(even|odd|eq|gt|lt|nth|first|last)(?:\\(" + whitespace +
			"*((?:-\\d)?\\d*)" + whitespace + "*\\)|)(?=[^-]|$)", "i" )
	},

	rhtml = /HTML$/i,
	rinputs = /^(?:input|select|textarea|button)$/i,
	rheader = /^h\d$/i,

	rnative = /^[^{]+\{\s*\[native \w/,

	rquickExpr = /^(?:#([\w-]+)|(\w+)|\.([\w-]+))$/,

	rsibling = /[+~]/,

	runescape = new RegExp( "\\\\[\\da-fA-F]{1,6}" + whitespace + "?|\\\\([^\\r\\n\\f])", "g" ),
	funescape = function( escape, nonHex ) {
		var high = "0x" + escape.slice( 1 ) - 0x10000;

		return nonHex ?

			nonHex :

			high < 0 ?
				String.fromCharCode( high + 0x10000 ) :
				String.fromCharCode( high >> 10 | 0xD800, high & 0x3FF | 0xDC00 );
	},

	rcssescape = /([\0-\x1f\x7f]|^-?\d)|^-$|[^\0-\x1f\x7f-\uFFFF\w-]/g,
	fcssescape = function( ch, asCodePoint ) {
		if ( asCodePoint ) {

			if ( ch === "\0" ) {
				return "\uFFFD";
			}

			return ch.slice( 0, -1 ) + "\\" +
				ch.charCodeAt( ch.length - 1 ).toString( 16 ) + " ";
		}

		return "\\" + ch;
	},

	unloadHandler = function() {
		setDocument();
	},

	inDisabledFieldset = addCombinator(
		function( elem ) {
			return elem.disabled === true && elem.nodeName.toLowerCase() === "fieldset";
		},
		{ dir: "parentNode", next: "legend" }
	);

try {
	push.apply(
		( arr = slice.call( preferredDoc.childNodes ) ),
		preferredDoc.childNodes
	);
	arr[ preferredDoc.childNodes.length ].nodeType;
} catch ( e ) {
	push = { apply: arr.length ?

		function( target, els ) {
			pushNative.apply( target, slice.call( els ) );
		} :
		function( target, els ) {
			var j = target.length,
				i = 0;

			while ( ( target[ j++ ] = els[ i++ ] ) ) {}
			target.length = j - 1;
		}
	};
}

function Sizzle( selector, context, results, seed ) {
	var m, i, elem, nid, match, groups, newSelector,
		newContext = context && context.ownerDocument,

		nodeType = context ? context.nodeType : 9;

	results = results || [];

	if ( typeof selector !== "string" || !selector ||
		nodeType !== 1 && nodeType !== 9 && nodeType !== 11 ) {

		return results;
	}

	if ( !seed ) {
		setDocument( context );
		context = context || document;

		if ( documentIsHTML ) {

			if ( nodeType !== 11 && ( match = rquickExpr.exec( selector ) ) ) {

				if ( ( m = match[ 1 ] ) ) {

					if ( nodeType === 9 ) {
						if ( ( elem = context.getElementById( m ) ) ) {
							if ( elem.id === m ) {
								results.push( elem );
								return results;
							}
						} else {
							return results;
						}

					// Element context
					} else {

						// Support: IE, Opera, Webkit
						// TODO: identify versions
						// getElementById can match elements by name instead of ID
						if ( newContext && ( elem = newContext.getElementById( m ) ) &&
							contains( context, elem ) &&
							elem.id === m ) {

							results.push( elem );
							return results;
						}
					}

				// Type selector
				} else if ( match[ 2 ] ) {
					push.apply( results, context.getElementsByTagName( selector ) );
					return results;

				// Class selector
				} else if ( ( m = match[ 3 ] ) && support.getElementsByClassName &&
					context.getElementsByClassName ) {

					push.apply( results, context.getElementsByClassName( m ) );
					return results;
				}
			}

			// Take advantage of querySelectorAll
			if ( support.qsa &&
				!nonnativeSelectorCache[ selector + " " ] &&
				( !rbuggyQSA || !rbuggyQSA.test( selector ) ) &&

				// Support: IE 8 only
				// Exclude object elements
				( nodeType !== 1 || context.nodeName.toLowerCase() !== "object" ) ) {

				newSelector = selector;
				newContext = context;

				// qSA considers elements outside a scoping root when evaluating child or
				// descendant combinators, which is not what we want.
				// In such cases, we work around the behavior by prefixing every selector in the
				// list with an ID selector referencing the scope context.
				// The technique has to be used as well when a leading combinator is used
				// as such selectors are not recognized by querySelectorAll.
				// Thanks to Andrew Dupont for this technique.
				if ( nodeType === 1 &&
					( rdescend.test( selector ) || rcombinators.test( selector ) ) ) {

					// Expand context for sibling selectors
					newContext = rsibling.test( selector ) && testContext( context.parentNode ) ||
						context;

					// We can use :scope instead of the ID hack if the browser
					// supports it & if we're not changing the context.
					if ( newContext !== context || !support.scope ) {

						// Capture the context ID, setting it first if necessary
						if ( ( nid = context.getAttribute( "id" ) ) ) {
							nid = nid.replace( rcssescape, fcssescape );
						} else {
							context.setAttribute( "id", ( nid = expando ) );
						}
					}

					// Prefix every selector in the list
					groups = tokenize( selector );
					i = groups.length;
					while ( i-- ) {
						groups[ i ] = ( nid ? "#" + nid : ":scope" ) + " " +
							toSelector( groups[ i ] );
					}
					newSelector = groups.join( "," );
				}

				try {
					push.apply( results,
						newContext.querySelectorAll( newSelector )
					);
					return results;
				} catch ( qsaError ) {
					nonnativeSelectorCache( selector, true );
				} finally {
					if ( nid === expando ) {
						context.removeAttribute( "id" );
					}
				}
			}
		}
	}

	// All others
	return select( selector.replace( rtrim, "$1" ), context, results, seed );
}

function createCache() {
	var keys = [];

	function cache( key, value ) {

		if ( keys.push( key + " " ) > Expr.cacheLength ) {

			delete cache[ keys.shift() ];
		}
		return ( cache[ key + " " ] = value );
	}
	return cache;
}


function markFunction( fn ) {
	fn[ expando ] = true;
	return fn;
}

function assert( fn ) {
	var el = document.createElement( "fieldset" );

	try {
		return !!fn( el );
	} catch ( e ) {
		return false;
	} finally {

		// Remove from its parent by default
		if ( el.parentNode ) {
			el.parentNode.removeChild( el );
		}

		// release memory in IE
		el = null;
	}
}

/**
 * Adds the same handler for all of the specified attrs
 * @param {String} attrs Pipe-separated list of attributes
 * @param {Function} handler The method that will be applied
 */
function addHandle( attrs, handler ) {
	var arr = attrs.split( "|" ),
		i = arr.length;

	while ( i-- ) {
		Expr.attrHandle[ arr[ i ] ] = handler;
	}
}

function siblingCheck( a, b ) {
	var cur = b && a,
		diff = cur && a.nodeType === 1 && b.nodeType === 1 &&
			a.sourceIndex - b.sourceIndex;

	if ( diff ) {
		return diff;
	}

	// Check if b follows a
	if ( cur ) {
		while ( ( cur = cur.nextSibling ) ) {
			if ( cur === b ) {
				return -1;
			}
		}
	}

	return a ? 1 : -1;
}

function createInputPseudo( type ) {
	return function( elem ) {
		var name = elem.nodeName.toLowerCase();
		return name === "input" && elem.type === type;
	};
}

function createButtonPseudo( type ) {
	return function( elem ) {
		var name = elem.nodeName.toLowerCase();
		return ( name === "input" || name === "button" ) && elem.type === type;
	};
}

function createDisabledPseudo( disabled ) {

	return function( elem ) {
		if ( "form" in elem ) {
			if ( elem.parentNode && elem.disabled === false ) {

				if ( "label" in elem ) {
					if ( "label" in elem.parentNode ) {
						return elem.parentNode.disabled === disabled;
					} else {
						return elem.disabled === disabled;
					}
				}
				return elem.isDisabled === disabled ||
					elem.isDisabled !== !disabled &&
					inDisabledFieldset( elem ) === disabled;
			}

			return elem.disabled === disabled;

		} else if ( "label" in elem ) {
			return elem.disabled === disabled;
		}

		return false;
	};
}

function createPositionalPseudo( fn ) {
	return markFunction( function( argument ) {
		argument = +argument;
		return markFunction( function( seed, matches ) {
			var j,
				matchIndexes = fn( [], seed.length, argument ),
				i = matchIndexes.length;

			// Match elements found at the specified indexes
			while ( i-- ) {
				if ( seed[ ( j = matchIndexes[ i ] ) ] ) {
					seed[ j ] = !( matches[ j ] = seed[ j ] );
				}
			}
		} );
	} );
}

function testContext( context ) {
	return context && typeof context.getElementsByTagName !== "undefined" && context;
}

support = Sizzle.support = {};

isXML = Sizzle.isXML = function( elem ) {
	var namespace = elem && elem.namespaceURI,
		docElem = elem && ( elem.ownerDocument || elem ).documentElement;
	return !rhtml.test( namespace || docElem && docElem.nodeName || "HTML" );
};

setDocument = Sizzle.setDocument = function( node ) {
	var hasCompare, subWindow,
		doc = node ? node.ownerDocument || node : preferredDoc;
	if ( doc == document || doc.nodeType !== 9 || !doc.documentElement ) {
		return document;
	}

	document = doc;
	docElem = document.documentElement;
	documentIsHTML = !isXML( document );


	if ( preferredDoc != document &&
		( subWindow = document.defaultView ) && subWindow.top !== subWindow ) {

		if ( subWindow.addEventListener ) {
			subWindow.addEventListener( "unload", unloadHandler, false );

		} else if ( subWindow.attachEvent ) {
			subWindow.attachEvent( "onunload", unloadHandler );
		}
	}

	support.scope = assert( function( el ) {
		docElem.appendChild( el ).appendChild( document.createElement( "div" ) );
		return typeof el.querySelectorAll !== "undefined" &&
			!el.querySelectorAll( ":scope fieldset div" ).length;
	} );


	support.attributes = assert( function( el ) {
		el.className = "i";
		return !el.getAttribute( "className" );
	} );

	support.getElementsByTagName = assert( function( el ) {
		el.appendChild( document.createComment( "" ) );
		return !el.getElementsByTagName( "*" ).length;
	} );

	support.getElementsByClassName = rnative.test( document.getElementsByClassName );

	support.getById = assert( function( el ) {
		docElem.appendChild( el ).id = expando;
		return !document.getElementsByName || !document.getElementsByName( expando ).length;
	} );

	if ( support.getById ) {
		Expr.filter[ "ID" ] = function( id ) {
			var attrId = id.replace( runescape, funescape );
			return function( elem ) {
				return elem.getAttribute( "id" ) === attrId;
			};
		};
		Expr.find[ "ID" ] = function( id, context ) {
			if ( typeof context.getElementById !== "undefined" && documentIsHTML ) {
				var elem = context.getElementById( id );
				return elem ? [ elem ] : [];
			}
		};
	} else {
		Expr.filter[ "ID" ] =  function( id ) {
			var attrId = id.replace( runescape, funescape );
			return function( elem ) {
				var node = typeof elem.getAttributeNode !== "undefined" &&
					elem.getAttributeNode( "id" );
				return node && node.value === attrId;
			};
		};

		Expr.find[ "ID" ] = function( id, context ) {
			if ( typeof context.getElementById !== "undefined" && documentIsHTML ) {
				var node, i, elems,
					elem = context.getElementById( id );

				if ( elem ) {

					// Verify the id attribute
					node = elem.getAttributeNode( "id" );
					if ( node && node.value === id ) {
						return [ elem ];
					}

					// Fall back on getElementsByName
					elems = context.getElementsByName( id );
					i = 0;
					while ( ( elem = elems[ i++ ] ) ) {
						node = elem.getAttributeNode( "id" );
						if ( node && node.value === id ) {
							return [ elem ];
						}
					}
				}

				return [];
			}
		};
	}

	Expr.find[ "TAG" ] = support.getElementsByTagName ?
		function( tag, context ) {
			if ( typeof context.getElementsByTagName !== "undefined" ) {
				return context.getElementsByTagName( tag );

			} else if ( support.qsa ) {
				return context.querySelectorAll( tag );
			}
		} :

		function( tag, context ) {
			var elem,
				tmp = [],
				i = 0,

				results = context.getElementsByTagName( tag );

			if ( tag === "*" ) {
				while ( ( elem = results[ i++ ] ) ) {
					if ( elem.nodeType === 1 ) {
						tmp.push( elem );
					}
				}

				return tmp;
			}
			return results;
		};

	Expr.find[ "CLASS" ] = support.getElementsByClassName && function( className, context ) {
		if ( typeof context.getElementsByClassName !== "undefined" && documentIsHTML ) {
			return context.getElementsByClassName( className );
		}
	};

	rbuggyMatches = [];

	rbuggyQSA = [];

	if ( ( support.qsa = rnative.test( document.querySelectorAll ) ) ) {

		assert( function( el ) {

			var input;
			docElem.appendChild( el ).innerHTML = "<a id='" + expando + "'></a>" +
				"<select id='" + expando + "-\r\\' msallowcapture=''>" +
				"<option selected=''></option></select>";

			if ( el.querySelectorAll( "[msallowcapture^='']" ).length ) {
				rbuggyQSA.push( "[*^$]=" + whitespace + "*(?:''|\"\")" );
			}

			if ( !el.querySelectorAll( "[selected]" ).length ) {
				rbuggyQSA.push( "\\[" + whitespace + "*(?:value|" + booleans + ")" );
			}

			if ( !el.querySelectorAll( "[id~=" + expando + "-]" ).length ) {
				rbuggyQSA.push( "~=" );
			}
			input = document.createElement( "input" );
			input.setAttribute( "name", "" );
			el.appendChild( input );
			if ( !el.querySelectorAll( "[name='']" ).length ) {
				rbuggyQSA.push( "\\[" + whitespace + "*name" + whitespace + "*=" +
					whitespace + "*(?:''|\"\")" );
			}

			if ( !el.querySelectorAll( ":checked" ).length ) {
				rbuggyQSA.push( ":checked" );
			}
			if ( !el.querySelectorAll( "a#" + expando + "+*" ).length ) {
				rbuggyQSA.push( ".#.+[+~]" );
			}
			el.querySelectorAll( "\\\f" );
			rbuggyQSA.push( "[\\r\\n\\f]" );
		} );

		assert( function( el ) {
			el.innerHTML = "<a href='' disabled='disabled'></a>" +
				"<select disabled='disabled'><option/></select>";

			var input = document.createElement( "input" );
			input.setAttribute( "type", "hidden" );
			el.appendChild( input ).setAttribute( "name", "D" );
			if ( el.querySelectorAll( "[name=d]" ).length ) {
				rbuggyQSA.push( "name" + whitespace + "*[*^$|!~]?=" );
			}
			if ( el.querySelectorAll( ":enabled" ).length !== 2 ) {
				rbuggyQSA.push( ":enabled", ":disabled" );
			}

			docElem.appendChild( el ).disabled = true;
			if ( el.querySelectorAll( ":disabled" ).length !== 2 ) {
				rbuggyQSA.push( ":enabled", ":disabled" );
			}

			el.querySelectorAll( "*,:x" );
			rbuggyQSA.push( ",.*:" );
		} );
	}

	if ( ( support.matchesSelector = rnative.test( ( matches = docElem.matches ||
		docElem.webkitMatchesSelector ||
		docElem.mozMatchesSelector ||
		docElem.oMatchesSelector ||
		docElem.msMatchesSelector ) ) ) ) {

		assert( function( el ) {
			support.disconnectedMatch = matches.call( el, "*" );
			matches.call( el, "[s!='']:x" );
			rbuggyMatches.push( "!=", pseudos );
		} );
	}

	rbuggyQSA = rbuggyQSA.length && new RegExp( rbuggyQSA.join( "|" ) );
	rbuggyMatches = rbuggyMatches.length && new RegExp( rbuggyMatches.join( "|" ) );
	hasCompare = rnative.test( docElem.compareDocumentPosition );

	contains = hasCompare || rnative.test( docElem.contains ) ?
		function( a, b ) {
			var adown = a.nodeType === 9 ? a.documentElement : a,
				bup = b && b.parentNode;
			return a === bup || !!( bup && bup.nodeType === 1 && (
				adown.contains ?
					adown.contains( bup ) :
					a.compareDocumentPosition && a.compareDocumentPosition( bup ) & 16
			) );
		} :
		function( a, b ) {
			if ( b ) {
				while ( ( b = b.parentNode ) ) {
					if ( b === a ) {
						return true;
					}
				}
			}
			return false;
		};

	sortOrder = hasCompare ?
	function( a, b ) {

		if ( a === b ) {
			hasDuplicate = true;
			return 0;
		}

		var compare = !a.compareDocumentPosition - !b.compareDocumentPosition;
		if ( compare ) {
			return compare;
		}

		compare = ( a.ownerDocument || a ) == ( b.ownerDocument || b ) ?
			a.compareDocumentPosition( b ) :

			1;

		if ( compare & 1 ||
			( !support.sortDetached && b.compareDocumentPosition( a ) === compare ) ) {

			if ( a == document || a.ownerDocument == preferredDoc &&
				contains( preferredDoc, a ) ) {
				return -1;
			}

			if ( b == document || b.ownerDocument == preferredDoc &&
				contains( preferredDoc, b ) ) {
				return 1;
			}

			return sortInput ?
				( indexOf( sortInput, a ) - indexOf( sortInput, b ) ) :
				0;
		}

		return compare & 4 ? -1 : 1;
	} :
	function( a, b ) {

		if ( a === b ) {
			hasDuplicate = true;
			return 0;
		}

		var cur,
			i = 0,
			aup = a.parentNode,
			bup = b.parentNode,
			ap = [ a ],
			bp = [ b ];

		if ( !aup || !bup ) {
			return a == document ? -1 :
				b == document ? 1 :
				aup ? -1 :
				bup ? 1 :
				sortInput ?
				( indexOf( sortInput, a ) - indexOf( sortInput, b ) ) :
				0;

		} else if ( aup === bup ) {
			return siblingCheck( a, b );
		}

		cur = a;
		while ( ( cur = cur.parentNode ) ) {
			ap.unshift( cur );
		}
		cur = b;
		while ( ( cur = cur.parentNode ) ) {
			bp.unshift( cur );
		}

		// Walk down the tree looking for a discrepancy
		while ( ap[ i ] === bp[ i ] ) {
			i++;
		}

		return i ?

			siblingCheck( ap[ i ], bp[ i ] ) :
			ap[ i ] == preferredDoc ? -1 :
			bp[ i ] == preferredDoc ? 1 :
			0;
	};

	return document;
};

Sizzle.matches = function( expr, elements ) {
	return Sizzle( expr, null, null, elements );
};

Sizzle.matchesSelector = function( elem, expr ) {
	setDocument( elem );

	if ( support.matchesSelector && documentIsHTML &&
		!nonnativeSelectorCache[ expr + " " ] &&
		( !rbuggyMatches || !rbuggyMatches.test( expr ) ) &&
		( !rbuggyQSA     || !rbuggyQSA.test( expr ) ) ) {

		try {
			var ret = matches.call( elem, expr );

			if ( ret || support.disconnectedMatch ||

				elem.document && elem.document.nodeType !== 11 ) {
				return ret;
			}
		} catch ( e ) {
			nonnativeSelectorCache( expr, true );
		}
	}

	return Sizzle( expr, document, null, [ elem ] ).length > 0;
};

Sizzle.contains = function( context, elem ) {
	if ( ( context.ownerDocument || context ) != document ) {
		setDocument( context );
	}
	return contains( context, elem );
};

Sizzle.attr = function( elem, name ) {
	if ( ( elem.ownerDocument || elem ) != document ) {
		setDocument( elem );
	}

	var fn = Expr.attrHandle[ name.toLowerCase() ],
		val = fn && hasOwn.call( Expr.attrHandle, name.toLowerCase() ) ?
			fn( elem, name, !documentIsHTML ) :
			undefined;

	return val !== undefined ?
		val :
		support.attributes || !documentIsHTML ?
			elem.getAttribute( name ) :
			( val = elem.getAttributeNode( name ) ) && val.specified ?
				val.value :
				null;
};

Sizzle.escape = function( sel ) {
	return ( sel + "" ).replace( rcssescape, fcssescape );
};

Sizzle.error = function( msg ) {
	throw new Error( "Syntax error, unrecognized expression: " + msg );
};

Sizzle.uniqueSort = function( results ) {
	var elem,
		duplicates = [],
		j = 0,
		i = 0;

	hasDuplicate = !support.detectDuplicates;
	sortInput = !support.sortStable && results.slice( 0 );
	results.sort( sortOrder );

	if ( hasDuplicate ) {
		while ( ( elem = results[ i++ ] ) ) {
			if ( elem === results[ i ] ) {
				j = duplicates.push( i );
			}
		}
		while ( j-- ) {
			results.splice( duplicates[ j ], 1 );
		}
	}

	sortInput = null;

	return results;
};

getText = Sizzle.getText = function( elem ) {
	var node,
		ret = "",
		i = 0,
		nodeType = elem.nodeType;

	if ( !nodeType ) {

		// If no nodeType, this is expected to be an array
		while ( ( node = elem[ i++ ] ) ) {

			// Do not traverse comment nodes
			ret += getText( node );
		}
	} else if ( nodeType === 1 || nodeType === 9 || nodeType === 11 ) {

		// Use textContent for elements
		// innerText usage removed for consistency of new lines (jQuery #11153)
		if ( typeof elem.textContent === "string" ) {
			return elem.textContent;
		} else {

			// Traverse its children
			for ( elem = elem.firstChild; elem; elem = elem.nextSibling ) {
				ret += getText( elem );
			}
		}
	} else if ( nodeType === 3 || nodeType === 4 ) {
		return elem.nodeValue;
	}

	// Do not include comment or processing instruction nodes

	return ret;
};

Expr = Sizzle.selectors = {

	cacheLength: 50,

	createPseudo: markFunction,

	match: matchExpr,

	attrHandle: {},

	find: {},

	relative: {
		">": { dir: "parentNode", first: true },
		" ": { dir: "parentNode" },
		"+": { dir: "previousSibling", first: true },
		"~": { dir: "previousSibling" }
	},

	preFilter: {
		"ATTR": function( match ) {
			match[ 1 ] = match[ 1 ].replace( runescape, funescape );

			// Move the given value to match[3] whether quoted or unquoted
			match[ 3 ] = ( match[ 3 ] || match[ 4 ] ||
				match[ 5 ] || "" ).replace( runescape, funescape );

			if ( match[ 2 ] === "~=" ) {
				match[ 3 ] = " " + match[ 3 ] + " ";
			}

			return match.slice( 0, 4 );
		},

		"CHILD": function( match ) {

			/* matches from matchExpr["CHILD"]
				1 type (only|nth|...)
				2 what (child|of-type)
				3 argument (even|odd|\d*|\d*n([+-]\d+)?|...)
				4 xn-component of xn+y argument ([+-]?\d*n|)
				5 sign of xn-component
				6 x of xn-component
				7 sign of y-component
				8 y of y-component
			*/
			match[ 1 ] = match[ 1 ].toLowerCase();

			if ( match[ 1 ].slice( 0, 3 ) === "nth" ) {

				// nth-* requires argument
				if ( !match[ 3 ] ) {
					Sizzle.error( match[ 0 ] );
				}

				// numeric x and y parameters for Expr.filter.CHILD
				// remember that false/true cast respectively to 0/1
				match[ 4 ] = +( match[ 4 ] ?
					match[ 5 ] + ( match[ 6 ] || 1 ) :
					2 * ( match[ 3 ] === "even" || match[ 3 ] === "odd" ) );
				match[ 5 ] = +( ( match[ 7 ] + match[ 8 ] ) || match[ 3 ] === "odd" );

				// other types prohibit arguments
			} else if ( match[ 3 ] ) {
				Sizzle.error( match[ 0 ] );
			}

			return match;
		},

		"PSEUDO": function( match ) {
			var excess,
				unquoted = !match[ 6 ] && match[ 2 ];

			if ( matchExpr[ "CHILD" ].test( match[ 0 ] ) ) {
				return null;
			}

			// Accept quoted arguments as-is
			if ( match[ 3 ] ) {
				match[ 2 ] = match[ 4 ] || match[ 5 ] || "";

			// Strip excess characters from unquoted arguments
			} else if ( unquoted && rpseudo.test( unquoted ) &&

				// Get excess from tokenize (recursively)
				( excess = tokenize( unquoted, true ) ) &&

				// advance to the next closing parenthesis
				( excess = unquoted.indexOf( ")", unquoted.length - excess ) - unquoted.length ) ) {

				// excess is a negative index
				match[ 0 ] = match[ 0 ].slice( 0, excess );
				match[ 2 ] = unquoted.slice( 0, excess );
			}

			// Return only captures needed by the pseudo filter method (type and argument)
			return match.slice( 0, 3 );
		}
	},

	filter: {

		"TAG": function( nodeNameSelector ) {
			var nodeName = nodeNameSelector.replace( runescape, funescape ).toLowerCase();
			return nodeNameSelector === "*" ?
				function() {
					return true;
				} :
				function( elem ) {
					return elem.nodeName && elem.nodeName.toLowerCase() === nodeName;
				};
		},

		"CLASS": function( className ) {
			var pattern = classCache[ className + " " ];

			return pattern ||
				( pattern = new RegExp( "(^|" + whitespace +
					")" + className + "(" + whitespace + "|$)" ) ) && classCache(
						className, function( elem ) {
							return pattern.test(
								typeof elem.className === "string" && elem.className ||
								typeof elem.getAttribute !== "undefined" &&
									elem.getAttribute( "class" ) ||
								""
							);
				} );
		},

		"ATTR": function( name, operator, check ) {
			return function( elem ) {
				var result = Sizzle.attr( elem, name );

				if ( result == null ) {
					return operator === "!=";
				}
				if ( !operator ) {
					return true;
				}

				result += "";

				/* eslint-disable max-len */

				return operator === "=" ? result === check :
					operator === "!=" ? result !== check :
					operator === "^=" ? check && result.indexOf( check ) === 0 :
					operator === "*=" ? check && result.indexOf( check ) > -1 :
					operator === "$=" ? check && result.slice( -check.length ) === check :
					operator === "~=" ? ( " " + result.replace( rwhitespace, " " ) + " " ).indexOf( check ) > -1 :
					operator === "|=" ? result === check || result.slice( 0, check.length + 1 ) === check + "-" :
					false;
				/* eslint-enable max-len */

			};
		},

		"CHILD": function( type, what, _argument, first, last ) {
			var simple = type.slice( 0, 3 ) !== "nth",
				forward = type.slice( -4 ) !== "last",
				ofType = what === "of-type";

			return first === 1 && last === 0 ?

				// Shortcut for :nth-*(n)
				function( elem ) {
					return !!elem.parentNode;
				} :

				function( elem, _context, xml ) {
					var cache, uniqueCache, outerCache, node, nodeIndex, start,
						dir = simple !== forward ? "nextSibling" : "previousSibling",
						parent = elem.parentNode,
						name = ofType && elem.nodeName.toLowerCase(),
						useCache = !xml && !ofType,
						diff = false;

					if ( parent ) {

						// :(first|last|only)-(child|of-type)
						if ( simple ) {
							while ( dir ) {
								node = elem;
								while ( ( node = node[ dir ] ) ) {
									if ( ofType ?
										node.nodeName.toLowerCase() === name :
										node.nodeType === 1 ) {

										return false;
									}
								}

								// Reverse direction for :only-* (if we haven't yet done so)
								start = dir = type === "only" && !start && "nextSibling";
							}
							return true;
						}

						start = [ forward ? parent.firstChild : parent.lastChild ];

						// non-xml :nth-child(...) stores cache data on `parent`
						if ( forward && useCache ) {

							// Seek `elem` from a previously-cached index

							// ...in a gzip-friendly way
							node = parent;
							outerCache = node[ expando ] || ( node[ expando ] = {} );

							// Support: IE <9 only
							// Defend against cloned attroperties (jQuery gh-1709)
							uniqueCache = outerCache[ node.uniqueID ] ||
								( outerCache[ node.uniqueID ] = {} );

							cache = uniqueCache[ type ] || [];
							nodeIndex = cache[ 0 ] === dirruns && cache[ 1 ];
							diff = nodeIndex && cache[ 2 ];
							node = nodeIndex && parent.childNodes[ nodeIndex ];

							while ( ( node = ++nodeIndex && node && node[ dir ] ||

								// Fallback to seeking `elem` from the start
								( diff = nodeIndex = 0 ) || start.pop() ) ) {

								// When found, cache indexes on `parent` and break
								if ( node.nodeType === 1 && ++diff && node === elem ) {
									uniqueCache[ type ] = [ dirruns, nodeIndex, diff ];
									break;
								}
							}

						} else {

							// Use previously-cached element index if available
							if ( useCache ) {

								// ...in a gzip-friendly way
								node = elem;
								outerCache = node[ expando ] || ( node[ expando ] = {} );

								// Support: IE <9 only
								// Defend against cloned attroperties (jQuery gh-1709)
								uniqueCache = outerCache[ node.uniqueID ] ||
									( outerCache[ node.uniqueID ] = {} );

								cache = uniqueCache[ type ] || [];
								nodeIndex = cache[ 0 ] === dirruns && cache[ 1 ];
								diff = nodeIndex;
							}

							// xml :nth-child(...)
							// or :nth-last-child(...) or :nth(-last)?-of-type(...)
							if ( diff === false ) {

								// Use the same loop as above to seek `elem` from the start
								while ( ( node = ++nodeIndex && node && node[ dir ] ||
									( diff = nodeIndex = 0 ) || start.pop() ) ) {

									if ( ( ofType ?
										node.nodeName.toLowerCase() === name :
										node.nodeType === 1 ) &&
										++diff ) {

										// Cache the index of each encountered element
										if ( useCache ) {
											outerCache = node[ expando ] ||
												( node[ expando ] = {} );

											// Support: IE <9 only
											// Defend against cloned attroperties (jQuery gh-1709)
											uniqueCache = outerCache[ node.uniqueID ] ||
												( outerCache[ node.uniqueID ] = {} );

											uniqueCache[ type ] = [ dirruns, diff ];
										}

										if ( node === elem ) {
											break;
										}
									}
								}
							}
						}

						// Incorporate the offset, then check against cycle size
						diff -= last;
						return diff === first || ( diff % first === 0 && diff / first >= 0 );
					}
				};
		},

		"PSEUDO": function( pseudo, argument ) {

			var args,
				fn = Expr.pseudos[ pseudo ] || Expr.setFilters[ pseudo.toLowerCase() ] ||
					Sizzle.error( "unsupported pseudo: " + pseudo );

			if ( fn[ expando ] ) {
				return fn( argument );
			}

			if ( fn.length > 1 ) {
				args = [ pseudo, pseudo, "", argument ];
				return Expr.setFilters.hasOwnProperty( pseudo.toLowerCase() ) ?
					markFunction( function( seed, matches ) {
						var idx,
							matched = fn( seed, argument ),
							i = matched.length;
						while ( i-- ) {
							idx = indexOf( seed, matched[ i ] );
							seed[ idx ] = !( matches[ idx ] = matched[ i ] );
						}
					} ) :
					function( elem ) {
						return fn( elem, 0, args );
					};
			}

			return fn;
		}
	},

	pseudos: {

		"not": markFunction( function( selector ) {

			var input = [],
				results = [],
				matcher = compile( selector.replace( rtrim, "$1" ) );

			return matcher[ expando ] ?
				markFunction( function( seed, matches, _context, xml ) {
					var elem,
						unmatched = matcher( seed, null, xml, [] ),
						i = seed.length;

					// Match elements unmatched by `matcher`
					while ( i-- ) {
						if ( ( elem = unmatched[ i ] ) ) {
							seed[ i ] = !( matches[ i ] = elem );
						}
					}
				} ) :
				function( elem, _context, xml ) {
					input[ 0 ] = elem;
					matcher( input, null, xml, results );

					// Don't keep the element (issue #299)
					input[ 0 ] = null;
					return !results.pop();
				};
		} ),

		"has": markFunction( function( selector ) {
			return function( elem ) {
				return Sizzle( selector, elem ).length > 0;
			};
		} ),

		"contains": markFunction( function( text ) {
			text = text.replace( runescape, funescape );
			return function( elem ) {
				return ( elem.textContent || getText( elem ) ).indexOf( text ) > -1;
			};
		} ),

		"lang": markFunction( function( lang ) {

			// lang value must be a valid identifier
			if ( !ridentifier.test( lang || "" ) ) {
				Sizzle.error( "unsupported lang: " + lang );
			}
			lang = lang.replace( runescape, funescape ).toLowerCase();
			return function( elem ) {
				var elemLang;
				do {
					if ( ( elemLang = documentIsHTML ?
						elem.lang :
						elem.getAttribute( "xml:lang" ) || elem.getAttribute( "lang" ) ) ) {

						elemLang = elemLang.toLowerCase();
						return elemLang === lang || elemLang.indexOf( lang + "-" ) === 0;
					}
				} while ( ( elem = elem.parentNode ) && elem.nodeType === 1 );
				return false;
			};
		} ),

		// Miscellaneous
		"target": function( elem ) {
			var hash = window.location && window.location.hash;
			return hash && hash.slice( 1 ) === elem.id;
		},

		"root": function( elem ) {
			return elem === docElem;
		},

		"focus": function( elem ) {
			return elem === document.activeElement &&
				( !document.hasFocus || document.hasFocus() ) &&
				!!( elem.type || elem.href || ~elem.tabIndex );
		},

		"enabled": createDisabledPseudo( false ),
		"disabled": createDisabledPseudo( true ),

		"checked": function( elem ) {
			var nodeName = elem.nodeName.toLowerCase();
			return ( nodeName === "input" && !!elem.checked ) ||
				( nodeName === "option" && !!elem.selected );
		},

		"selected": function( elem ) {
			if ( elem.parentNode ) {
				elem.parentNode.selectedIndex;
			}

			return elem.selected === true;
		},
		"empty": function( elem ) {
			for ( elem = elem.firstChild; elem; elem = elem.nextSibling ) {
				if ( elem.nodeType < 6 ) {
					return false;
				}
			}
			return true;
		},

		"parent": function( elem ) {
			return !Expr.pseudos[ "empty" ]( elem );
		},

		"header": function( elem ) {
			return rheader.test( elem.nodeName );
		},

		"input": function( elem ) {
			return rinputs.test( elem.nodeName );
		},

		"button": function( elem ) {
			var name = elem.nodeName.toLowerCase();
			return name === "input" && elem.type === "button" || name === "button";
		},

		"text": function( elem ) {
			var attr;
			return elem.nodeName.toLowerCase() === "input" &&
				elem.type === "text" &&
				( ( attr = elem.getAttribute( "type" ) ) == null ||
					attr.toLowerCase() === "text" );
		},

		// Position-in-collection
		"first": createPositionalPseudo( function() {
			return [ 0 ];
		} ),

		"last": createPositionalPseudo( function( _matchIndexes, length ) {
			return [ length - 1 ];
		} ),

		"eq": createPositionalPseudo( function( _matchIndexes, length, argument ) {
			return [ argument < 0 ? argument + length : argument ];
		} ),

		"even": createPositionalPseudo( function( matchIndexes, length ) {
			var i = 0;
			for ( ; i < length; i += 2 ) {
				matchIndexes.push( i );
			}
			return matchIndexes;
		} ),

		"odd": createPositionalPseudo( function( matchIndexes, length ) {
			var i = 1;
			for ( ; i < length; i += 2 ) {
				matchIndexes.push( i );
			}
			return matchIndexes;
		} ),

		"lt": createPositionalPseudo( function( matchIndexes, length, argument ) {
			var i = argument < 0 ?
				argument + length :
				argument > length ?
					length :
					argument;
			for ( ; --i >= 0; ) {
				matchIndexes.push( i );
			}
			return matchIndexes;
		} ),

		"gt": createPositionalPseudo( function( matchIndexes, length, argument ) {
			var i = argument < 0 ? argument + length : argument;
			for ( ; ++i < length; ) {
				matchIndexes.push( i );
			}
			return matchIndexes;
		} )
	}
};

Expr.pseudos[ "nth" ] = Expr.pseudos[ "eq" ];

for ( i in { radio: true, checkbox: true, file: true, password: true, image: true } ) {
	Expr.pseudos[ i ] = createInputPseudo( i );
}
for ( i in { submit: true, reset: true } ) {
	Expr.pseudos[ i ] = createButtonPseudo( i );
}

function setFilters() {}
setFilters.prototype = Expr.filters = Expr.pseudos;
Expr.setFilters = new setFilters();

tokenize = Sizzle.tokenize = function( selector, parseOnly ) {
	var matched, match, tokens, type,
		soFar, groups, preFilters,
		cached = tokenCache[ selector + " " ];

	if ( cached ) {
		return parseOnly ? 0 : cached.slice( 0 );
	}

	soFar = selector;
	groups = [];
	preFilters = Expr.preFilter;

	while ( soFar ) {

		if ( !matched || ( match = rcomma.exec( soFar ) ) ) {
			if ( match ) {

				// Don't consume trailing commas as valid
				soFar = soFar.slice( match[ 0 ].length ) || soFar;
			}
			groups.push( ( tokens = [] ) );
		}

		matched = false;

		if ( ( match = rcombinators.exec( soFar ) ) ) {
			matched = match.shift();
			tokens.push( {
				value: matched,

				type: match[ 0 ].replace( rtrim, " " )
			} );
			soFar = soFar.slice( matched.length );
		}

		// Filters
		for ( type in Expr.filter ) {
			if ( ( match = matchExpr[ type ].exec( soFar ) ) && ( !preFilters[ type ] ||
				( match = preFilters[ type ]( match ) ) ) ) {
				matched = match.shift();
				tokens.push( {
					value: matched,
					type: type,
					matches: match
				} );
				soFar = soFar.slice( matched.length );
			}
		}

		if ( !matched ) {
			break;
		}
	}

	// Return the length of the invalid excess
	// if we're just parsing
	// Otherwise, throw an error or return tokens
	return parseOnly ?
		soFar.length :
		soFar ?
			Sizzle.error( selector ) :

			// Cache the tokens
			tokenCache( selector, groups ).slice( 0 );
};

function toSelector( tokens ) {
	var i = 0,
		len = tokens.length,
		selector = "";
	for ( ; i < len; i++ ) {
		selector += tokens[ i ].value;
	}
	return selector;
}

function addCombinator( matcher, combinator, base ) {
	var dir = combinator.dir,
		skip = combinator.next,
		key = skip || dir,
		checkNonElements = base && key === "parentNode",
		doneName = done++;

	return combinator.first ?

		// Check against closest ancestor/preceding element
		function( elem, context, xml ) {
			while ( ( elem = elem[ dir ] ) ) {
				if ( elem.nodeType === 1 || checkNonElements ) {
					return matcher( elem, context, xml );
				}
			}
			return false;
		} :

		// Check against all ancestor/preceding elements
		function( elem, context, xml ) {
			var oldCache, uniqueCache, outerCache,
				newCache = [ dirruns, doneName ];

			// We can't set arbitrary data on XML nodes, so they don't benefit from combinator caching
			if ( xml ) {
				while ( ( elem = elem[ dir ] ) ) {
					if ( elem.nodeType === 1 || checkNonElements ) {
						if ( matcher( elem, context, xml ) ) {
							return true;
						}
					}
				}
			} else {
				while ( ( elem = elem[ dir ] ) ) {
					if ( elem.nodeType === 1 || checkNonElements ) {
						outerCache = elem[ expando ] || ( elem[ expando ] = {} );

						// Support: IE <9 only
						// Defend against cloned attroperties (jQuery gh-1709)
						uniqueCache = outerCache[ elem.uniqueID ] ||
							( outerCache[ elem.uniqueID ] = {} );

						if ( skip && skip === elem.nodeName.toLowerCase() ) {
							elem = elem[ dir ] || elem;
						} else if ( ( oldCache = uniqueCache[ key ] ) &&
							oldCache[ 0 ] === dirruns && oldCache[ 1 ] === doneName ) {

							// Assign to newCache so results back-propagate to previous elements
							return ( newCache[ 2 ] = oldCache[ 2 ] );
						} else {

							// Reuse newcache so results back-propagate to previous elements
							uniqueCache[ key ] = newCache;

							// A match means we're done; a fail means we have to keep checking
							if ( ( newCache[ 2 ] = matcher( elem, context, xml ) ) ) {
								return true;
							}
						}
					}
				}
			}
			return false;
		};
}

function elementMatcher( matchers ) {
	return matchers.length > 1 ?
		function( elem, context, xml ) {
			var i = matchers.length;
			while ( i-- ) {
				if ( !matchers[ i ]( elem, context, xml ) ) {
					return false;
				}
			}
			return true;
		} :
		matchers[ 0 ];
}

function multipleContexts( selector, contexts, results ) {
	var i = 0,
		len = contexts.length;
	for ( ; i < len; i++ ) {
		Sizzle( selector, contexts[ i ], results );
	}
	return results;
}

function condense( unmatched, map, filter, context, xml ) {
	var elem,
		newUnmatched = [],
		i = 0,
		len = unmatched.length,
		mapped = map != null;

	for ( ; i < len; i++ ) {
		if ( ( elem = unmatched[ i ] ) ) {
			if ( !filter || filter( elem, context, xml ) ) {
				newUnmatched.push( elem );
				if ( mapped ) {
					map.push( i );
				}
			}
		}
	}

	return newUnmatched;
}

function setMatcher( preFilter, selector, matcher, postFilter, postFinder, postSelector ) {
	if ( postFilter && !postFilter[ expando ] ) {
		postFilter = setMatcher( postFilter );
	}
	if ( postFinder && !postFinder[ expando ] ) {
		postFinder = setMatcher( postFinder, postSelector );
	}
	return markFunction( function( seed, results, context, xml ) {
		var temp, i, elem,
			preMap = [],
			postMap = [],
			preexisting = results.length,

			// Get initial elements from seed or context
			elems = seed || multipleContexts(
				selector || "*",
				context.nodeType ? [ context ] : context,
				[]
			),

			// Prefilter to get matcher input, preserving a map for seed-results synchronization
			matcherIn = preFilter && ( seed || !selector ) ?
				condense( elems, preMap, preFilter, context, xml ) :
				elems,

			matcherOut = matcher ?

				// If we have a postFinder, or filtered seed, or non-seed postFilter or preexisting results,
				postFinder || ( seed ? preFilter : preexisting || postFilter ) ?

					// ...intermediate processing is necessary
					[] :

					// ...otherwise use results directly
					results :
				matcherIn;

		// Find primary matches
		if ( matcher ) {
			matcher( matcherIn, matcherOut, context, xml );
		}

		// Apply postFilter
		if ( postFilter ) {
			temp = condense( matcherOut, postMap );
			postFilter( temp, [], context, xml );

			// Un-match failing elements by moving them back to matcherIn
			i = temp.length;
			while ( i-- ) {
				if ( ( elem = temp[ i ] ) ) {
					matcherOut[ postMap[ i ] ] = !( matcherIn[ postMap[ i ] ] = elem );
				}
			}
		}

		if ( seed ) {
			if ( postFinder || preFilter ) {
				if ( postFinder ) {

					// Get the final matcherOut by condensing this intermediate into postFinder contexts
					temp = [];
					i = matcherOut.length;
					while ( i-- ) {
						if ( ( elem = matcherOut[ i ] ) ) {

							// Restore matcherIn since elem is not yet a final match
							temp.push( ( matcherIn[ i ] = elem ) );
						}
					}
					postFinder( null, ( matcherOut = [] ), temp, xml );
				}

				// Move matched elements from seed to results to keep them synchronized
				i = matcherOut.length;
				while ( i-- ) {
					if ( ( elem = matcherOut[ i ] ) &&
						( temp = postFinder ? indexOf( seed, elem ) : preMap[ i ] ) > -1 ) {

						seed[ temp ] = !( results[ temp ] = elem );
					}
				}
			}

		// Add elements to results, through postFinder if defined
		} else {
			matcherOut = condense(
				matcherOut === results ?
					matcherOut.splice( preexisting, matcherOut.length ) :
					matcherOut
			);
			if ( postFinder ) {
				postFinder( null, results, matcherOut, xml );
			} else {
				push.apply( results, matcherOut );
			}
		}
	} );
}

function matcherFromTokens( tokens ) {
	var checkContext, matcher, j,
		len = tokens.length,
		leadingRelative = Expr.relative[ tokens[ 0 ].type ],
		implicitRelative = leadingRelative || Expr.relative[ " " ],
		i = leadingRelative ? 1 : 0,

		matchContext = addCombinator( function( elem ) {
			return elem === checkContext;
		}, implicitRelative, true ),
		matchAnyContext = addCombinator( function( elem ) {
			return indexOf( checkContext, elem ) > -1;
		}, implicitRelative, true ),
		matchers = [ function( elem, context, xml ) {
			var ret = ( !leadingRelative && ( xml || context !== outermostContext ) ) || (
				( checkContext = context ).nodeType ?
					matchContext( elem, context, xml ) :
					matchAnyContext( elem, context, xml ) );

			checkContext = null;
			return ret;
		} ];

	for ( ; i < len; i++ ) {
		if ( ( matcher = Expr.relative[ tokens[ i ].type ] ) ) {
			matchers = [ addCombinator( elementMatcher( matchers ), matcher ) ];
		} else {
			matcher = Expr.filter[ tokens[ i ].type ].apply( null, tokens[ i ].matches );

			if ( matcher[ expando ] ) {

				j = ++i;
				for ( ; j < len; j++ ) {
					if ( Expr.relative[ tokens[ j ].type ] ) {
						break;
					}
				}
				return setMatcher(
					i > 1 && elementMatcher( matchers ),
					i > 1 && toSelector(

					tokens
						.slice( 0, i - 1 )
						.concat( { value: tokens[ i - 2 ].type === " " ? "*" : "" } )
					).replace( rtrim, "$1" ),
					matcher,
					i < j && matcherFromTokens( tokens.slice( i, j ) ),
					j < len && matcherFromTokens( ( tokens = tokens.slice( j ) ) ),
					j < len && toSelector( tokens )
				);
			}
			matchers.push( matcher );
		}
	}

	return elementMatcher( matchers );
}

function matcherFromGroupMatchers( elementMatchers, setMatchers ) {
	var bySet = setMatchers.length > 0,
		byElement = elementMatchers.length > 0,
		superMatcher = function( seed, context, xml, results, outermost ) {
			var elem, j, matcher,
				matchedCount = 0,
				i = "0",
				unmatched = seed && [],
				setMatched = [],
				contextBackup = outermostContext,

				elems = seed || byElement && Expr.find[ "TAG" ]( "*", outermost ),

				dirrunsUnique = ( dirruns += contextBackup == null ? 1 : Math.random() || 0.1 ),
				len = elems.length;

			if ( outermost ) {
				outermostContext = context == document || context || outermost;
			}
			for ( ; i !== len && ( elem = elems[ i ] ) != null; i++ ) {
				if ( byElement && elem ) {
					j = 0;
					if ( !context && elem.ownerDocument != document ) {
						setDocument( elem );
						xml = !documentIsHTML;
					}
					while ( ( matcher = elementMatchers[ j++ ] ) ) {
						if ( matcher( elem, context || document, xml ) ) {
							results.push( elem );
							break;
						}
					}
					if ( outermost ) {
						dirruns = dirrunsUnique;
					}
				}

				if ( bySet ) {

					if ( ( elem = !matcher && elem ) ) {
						matchedCount--;
					}

					if ( seed ) {
						unmatched.push( elem );
					}
				}
			}
			matchedCount += i;
			if ( bySet && i !== matchedCount ) {
				j = 0;
				while ( ( matcher = setMatchers[ j++ ] ) ) {
					matcher( unmatched, setMatched, context, xml );
				}

				if ( seed ) {

					if ( matchedCount > 0 ) {
						while ( i-- ) {
							if ( !( unmatched[ i ] || setMatched[ i ] ) ) {
								setMatched[ i ] = pop.call( results );
							}
						}
					}

					setMatched = condense( setMatched );
				}

				push.apply( results, setMatched );

				if ( outermost && !seed && setMatched.length > 0 &&
					( matchedCount + setMatchers.length ) > 1 ) {

					Sizzle.uniqueSort( results );
				}
			}

			if ( outermost ) {
				dirruns = dirrunsUnique;
				outermostContext = contextBackup;
			}

			return unmatched;
		};

	return bySet ?
		markFunction( superMatcher ) :
		superMatcher;
}

compile = Sizzle.compile = function( selector, match /* Internal Use Only */ ) {
	var i,
		setMatchers = [],
		elementMatchers = [],
		cached = compilerCache[ selector + " " ];

	if ( !cached ) {

		if ( !match ) {
			match = tokenize( selector );
		}
		i = match.length;
		while ( i-- ) {
			cached = matcherFromTokens( match[ i ] );
			if ( cached[ expando ] ) {
				setMatchers.push( cached );
			} else {
				elementMatchers.push( cached );
			}
		}

		cached = compilerCache(
			selector,
			matcherFromGroupMatchers( elementMatchers, setMatchers )
		);

		cached.selector = selector;
	}
	return cached;
};

select = Sizzle.select = function( selector, context, results, seed ) {
	var i, tokens, token, type, find,
		compiled = typeof selector === "function" && selector,
		match = !seed && tokenize( ( selector = compiled.selector || selector ) );

	results = results || [];
	if ( match.length === 1 ) {

		tokens = match[ 0 ] = match[ 0 ].slice( 0 );
		if ( tokens.length > 2 && ( token = tokens[ 0 ] ).type === "ID" &&
			context.nodeType === 9 && documentIsHTML && Expr.relative[ tokens[ 1 ].type ] ) {

			context = ( Expr.find[ "ID" ]( token.matches[ 0 ]
				.replace( runescape, funescape ), context ) || [] )[ 0 ];
			if ( !context ) {
				return results;

			} else if ( compiled ) {
				context = context.parentNode;
			}

			selector = selector.slice( tokens.shift().value.length );
		}

		i = matchExpr[ "needsContext" ].test( selector ) ? 0 : tokens.length;
		while ( i-- ) {
			token = tokens[ i ];

			if ( Expr.relative[ ( type = token.type ) ] ) {
				break;
			}
			if ( ( find = Expr.find[ type ] ) ) {

				if ( ( seed = find(
					token.matches[ 0 ].replace( runescape, funescape ),
					rsibling.test( tokens[ 0 ].type ) && testContext( context.parentNode ) ||
						context
				) ) ) {

					tokens.splice( i, 1 );
					selector = seed.length && toSelector( tokens );
					if ( !selector ) {
						push.apply( results, seed );
						return results;
					}

					break;
				}
			}
		}
	}
	( compiled || compile( selector, match ) )(
		seed,
		context,
		!documentIsHTML,
		results,
		!context || rsibling.test( selector ) && testContext( context.parentNode ) || context
	);
	return results;
};

support.sortStable = expando.split( "" ).sort( sortOrder ).join( "" ) === expando;
support.detectDuplicates = !!hasDuplicate;
setDocument();

support.sortDetached = assert( function( el ) {

	return el.compareDocumentPosition( document.createElement( "fieldset" ) ) & 1;
} );


if ( !assert( function( el ) {
	el.innerHTML = "<a href='#'></a>";
	return el.firstChild.getAttribute( "href" ) === "#";
} ) ) {
	addHandle( "type|href|height|width", function( elem, name, isXML ) {
		if ( !isXML ) {
			return elem.getAttribute( name, name.toLowerCase() === "type" ? 1 : 2 );
		}
	} );
}

if ( !support.attributes || !assert( function( el ) {
	el.innerHTML = "<input/>";
	el.firstChild.setAttribute( "value", "" );
	return el.firstChild.getAttribute( "value" ) === "";
} ) ) {
	addHandle( "value", function( elem, _name, isXML ) {
		if ( !isXML && elem.nodeName.toLowerCase() === "input" ) {
			return elem.defaultValue;
		}
	} );
}

if ( !assert( function( el ) {
	return el.getAttribute( "disabled" ) == null;
} ) ) {
	addHandle( booleans, function( elem, name, isXML ) {
		var val;
		if ( !isXML ) {
			return elem[ name ] === true ? name.toLowerCase() :
				( val = elem.getAttributeNode( name ) ) && val.specified ?
					val.value :
					null;
		}
	} );
}

return Sizzle;

} )( window );



jQuery.find = Sizzle;
jQuery.expr = Sizzle.selectors;

jQuery.expr[ ":" ] = jQuery.expr.pseudos;
jQuery.uniqueSort = jQuery.unique = Sizzle.uniqueSort;
jQuery.text = Sizzle.getText;
jQuery.isXMLDoc = Sizzle.isXML;
jQuery.contains = Sizzle.contains;
jQuery.escapeSelector = Sizzle.escape;




var dir = function( elem, dir, until ) {
	var matched = [],
		truncate = until !== undefined;

	while ( ( elem = elem[ dir ] ) && elem.nodeType !== 9 ) {
		if ( elem.nodeType === 1 ) {
			if ( truncate && jQuery( elem ).is( until ) ) {
				break;
			}
			matched.push( elem );
		}
	}
	return matched;
};


var siblings = function( n, elem ) {
	var matched = [];

	for ( ; n; n = n.nextSibling ) {
		if ( n.nodeType === 1 && n !== elem ) {
			matched.push( n );
		}
	}

	return matched;
};


var rneedsContext = jQuery.expr.match.needsContext;



function nodeName( elem, name ) {

	return elem.nodeName && elem.nodeName.toLowerCase() === name.toLowerCase();

}
var rsingleTag = ( /^<([a-z][^\/\0>:\x20\t\r\n\f]*)[\x20\t\r\n\f]*\/?>(?:<\/\1>|)$/i );



function winnow( elements, qualifier, not ) {
	if ( isFunction( qualifier ) ) {
		return jQuery.grep( elements, function( elem, i ) {
			return !!qualifier.call( elem, i, elem ) !== not;
		} );
	}

	if ( qualifier.nodeType ) {
		return jQuery.grep( elements, function( elem ) {
			return ( elem === qualifier ) !== not;
		} );
	}

	if ( typeof qualifier !== "string" ) {
		return jQuery.grep( elements, function( elem ) {
			return ( indexOf.call( qualifier, elem ) > -1 ) !== not;
		} );
	}

	return jQuery.filter( qualifier, elements, not );
}

jQuery.filter = function( expr, elems, not ) {
	var elem = elems[ 0 ];

	if ( not ) {
		expr = ":not(" + expr + ")";
	}

	if ( elems.length === 1 && elem.nodeType === 1 ) {
		return jQuery.find.matchesSelector( elem, expr ) ? [ elem ] : [];
	}

	return jQuery.find.matches( expr, jQuery.grep( elems, function( elem ) {
		return elem.nodeType === 1;
	} ) );
};

jQuery.fn.extend( {
	find: function( selector ) {
		var i, ret,
			len = this.length,
			self = this;

		if ( typeof selector !== "string" ) {
			return this.pushStack( jQuery( selector ).filter( function() {
				for ( i = 0; i < len; i++ ) {
					if ( jQuery.contains( self[ i ], this ) ) {
						return true;
					}
				}
			} ) );
		}

		ret = this.pushStack( [] );

		for ( i = 0; i < len; i++ ) {
			jQuery.find( selector, self[ i ], ret );
		}

		return len > 1 ? jQuery.uniqueSort( ret ) : ret;
	},
	filter: function( selector ) {
		return this.pushStack( winnow( this, selector || [], false ) );
	},
	not: function( selector ) {
		return this.pushStack( winnow( this, selector || [], true ) );
	},
	is: function( selector ) {
		return !!winnow(
			this,
			typeof selector === "string" && rneedsContext.test( selector ) ?
				jQuery( selector ) :
				selector || [],
			false
		).length;
	}
} );


var rootjQuery,
	rquickExpr = /^(?:\s*(<[\w\W]+>)[^>]*|#([\w-]+))$/,

	init = jQuery.fn.init = function( selector, context, root ) {
		var match, elem;

		if ( !selector ) {
			return this;
		}

		root = root || rootjQuery;

		if ( typeof selector === "string" ) {
			if ( selector[ 0 ] === "<" &&
				selector[ selector.length - 1 ] === ">" &&
				selector.length >= 3 ) {

				match = [ null, selector, null ];

			} else {
				match = rquickExpr.exec( selector );
			}

			if ( match && ( match[ 1 ] || !context ) ) {

				if ( match[ 1 ] ) {
					context = context instanceof jQuery ? context[ 0 ] : context;

					jQuery.merge( this, jQuery.parseHTML(
						match[ 1 ],
						context && context.nodeType ? context.ownerDocument || context : document,
						true
					) );

					if ( rsingleTag.test( match[ 1 ] ) && jQuery.isPlainObject( context ) ) {
						for ( match in context ) {

							if ( isFunction( this[ match ] ) ) {
								this[ match ]( context[ match ] );
							} else {
								this.attr( match, context[ match ] );
							}
						}
					}

					return this;

				} else {
					elem = document.getElementById( match[ 2 ] );

					if ( elem ) {

						// Inject the element directly into the jQuery object
						this[ 0 ] = elem;
						this.length = 1;
					}
					return this;
				}

			} else if ( !context || context.jquery ) {
				return ( context || root ).find( selector );

			} else {
				return this.constructor( context ).find( selector );
			}

		} else if ( selector.nodeType ) {
			this[ 0 ] = selector;
			this.length = 1;
			return this;

		// HANDLE: $(function)
		// Shortcut for document ready
		} else if ( isFunction( selector ) ) {
			return root.ready !== undefined ?
				root.ready( selector ) :

				// Execute immediately if ready is not present
				selector( jQuery );
		}

		return jQuery.makeArray( selector, this );
	};

init.prototype = jQuery.fn;

rootjQuery = jQuery( document );


var rparentsprev = /^(?:parents|prev(?:Until|All))/,

	guaranteedUnique = {
		children: true,
		contents: true,
		next: true,
		prev: true
	};

jQuery.fn.extend( {
	has: function( target ) {
		var targets = jQuery( target, this ),
			l = targets.length;

		return this.filter( function() {
			var i = 0;
			for ( ; i < l; i++ ) {
				if ( jQuery.contains( this, targets[ i ] ) ) {
					return true;
				}
			}
		} );
	},

	closest: function( selectors, context ) {
		var cur,
			i = 0,
			l = this.length,
			matched = [],
			targets = typeof selectors !== "string" && jQuery( selectors );

		if ( !rneedsContext.test( selectors ) ) {
			for ( ; i < l; i++ ) {
				for ( cur = this[ i ]; cur && cur !== context; cur = cur.parentNode ) {

					if ( cur.nodeType < 11 && ( targets ?
						targets.index( cur ) > -1 :

						cur.nodeType === 1 &&
							jQuery.find.matchesSelector( cur, selectors ) ) ) {

						matched.push( cur );
						break;
					}
				}
			}
		}

		return this.pushStack( matched.length > 1 ? jQuery.uniqueSort( matched ) : matched );
	},

	index: function( elem ) {

		if ( !elem ) {
			return ( this[ 0 ] && this[ 0 ].parentNode ) ? this.first().prevAll().length : -1;
		}

		if ( typeof elem === "string" ) {
			return indexOf.call( jQuery( elem ), this[ 0 ] );
		}

		return indexOf.call( this,

			elem.jquery ? elem[ 0 ] : elem
		);
	},

	add: function( selector, context ) {
		return this.pushStack(
			jQuery.uniqueSort(
				jQuery.merge( this.get(), jQuery( selector, context ) )
			)
		);
	},

	addBack: function( selector ) {
		return this.add( selector == null ?
			this.prevObject : this.prevObject.filter( selector )
		);
	}
} );

function sibling( cur, dir ) {
	while ( ( cur = cur[ dir ] ) && cur.nodeType !== 1 ) {}
	return cur;
}

jQuery.each( {
	parent: function( elem ) {
		var parent = elem.parentNode;
		return parent && parent.nodeType !== 11 ? parent : null;
	},
	parents: function( elem ) {
		return dir( elem, "parentNode" );
	},
	parentsUntil: function( elem, _i, until ) {
		return dir( elem, "parentNode", until );
	},
	next: function( elem ) {
		return sibling( elem, "nextSibling" );
	},
	prev: function( elem ) {
		return sibling( elem, "previousSibling" );
	},
	nextAll: function( elem ) {
		return dir( elem, "nextSibling" );
	},
	prevAll: function( elem ) {
		return dir( elem, "previousSibling" );
	},
	nextUntil: function( elem, _i, until ) {
		return dir( elem, "nextSibling", until );
	},
	prevUntil: function( elem, _i, until ) {
		return dir( elem, "previousSibling", until );
	},
	siblings: function( elem ) {
		return siblings( ( elem.parentNode || {} ).firstChild, elem );
	},
	children: function( elem ) {
		return siblings( elem.firstChild );
	},
	contents: function( elem ) {
		if ( elem.contentDocument != null &&

			getProto( elem.contentDocument ) ) {

			return elem.contentDocument;
		}

		if ( nodeName( elem, "template" ) ) {
			elem = elem.content || elem;
		}

		return jQuery.merge( [], elem.childNodes );
	}
}, function( name, fn ) {
	jQuery.fn[ name ] = function( until, selector ) {
		var matched = jQuery.map( this, fn, until );

		if ( name.slice( -5 ) !== "Until" ) {
			selector = until;
		}

		if ( selector && typeof selector === "string" ) {
			matched = jQuery.filter( selector, matched );
		}

		if ( this.length > 1 ) {

			// Remove duplicates
			if ( !guaranteedUnique[ name ] ) {
				jQuery.uniqueSort( matched );
			}

			// Reverse order for parents* and prev-derivatives
			if ( rparentsprev.test( name ) ) {
				matched.reverse();
			}
		}

		return this.pushStack( matched );
	};
} );
var rnothtmlwhite = ( /[^\x20\t\r\n\f]+/g );



function createOptions( options ) {
	var object = {};
	jQuery.each( options.match( rnothtmlwhite ) || [], function( _, flag ) {
		object[ flag ] = true;
	} );
	return object;
}


jQuery.Callbacks = function( options ) {

	options = typeof options === "string" ?
		createOptions( options ) :
		jQuery.extend( {}, options );

	var // Flag to know if list is currently firing
		firing,

		// Last fire value for non-forgettable lists
		memory,

		// Flag to know if list was already fired
		fired,

		// Flag to prevent firing
		locked,

		// Actual callback list
		list = [],

		// Queue of execution data for repeatable lists
		queue = [],

		// Index of currently firing callback (modified by add/remove as needed)
		firingIndex = -1,

		// Fire callbacks
		fire = function() {

			// Enforce single-firing
			locked = locked || options.once;

			// Execute callbacks for all pending executions,
			// respecting firingIndex overrides and runtime changes
			fired = firing = true;
			for ( ; queue.length; firingIndex = -1 ) {
				memory = queue.shift();
				while ( ++firingIndex < list.length ) {

					// Run callback and check for early termination
					if ( list[ firingIndex ].apply( memory[ 0 ], memory[ 1 ] ) === false &&
						options.stopOnFalse ) {

						// Jump to end and forget the data so .add doesn't re-fire
						firingIndex = list.length;
						memory = false;
					}
				}
			}

			// Forget the data if we're done with it
			if ( !options.memory ) {
				memory = false;
			}

			firing = false;

			// Clean up if we're done firing for good
			if ( locked ) {

				// Keep an empty list if we have data for future add calls
				if ( memory ) {
					list = [];

				// Otherwise, this object is spent
				} else {
					list = "";
				}
			}
		},

		// Actual Callbacks object
		self = {

			// Add a callback or a collection of callbacks to the list
			add: function() {
				if ( list ) {

					// If we have memory from a past run, we should fire after adding
					if ( memory && !firing ) {
						firingIndex = list.length - 1;
						queue.push( memory );
					}

					( function add( args ) {
						jQuery.each( args, function( _, arg ) {
							if ( isFunction( arg ) ) {
								if ( !options.unique || !self.has( arg ) ) {
									list.push( arg );
								}
							} else if ( arg && arg.length && toType( arg ) !== "string" ) {

								// Inspect recursively
								add( arg );
							}
						} );
					} )( arguments );

					if ( memory && !firing ) {
						fire();
					}
				}
				return this;
			},

			// Remove a callback from the list
			remove: function() {
				jQuery.each( arguments, function( _, arg ) {
					var index;
					while ( ( index = jQuery.inArray( arg, list, index ) ) > -1 ) {
						list.splice( index, 1 );

						// Handle firing indexes
						if ( index <= firingIndex ) {
							firingIndex--;
						}
					}
				} );
				return this;
			},

			// Check if a given callback is in the list.
			// If no argument is given, return whether or not list has callbacks attached.
			has: function( fn ) {
				return fn ?
					jQuery.inArray( fn, list ) > -1 :
					list.length > 0;
			},

			// Remove all callbacks from the list
			empty: function() {
				if ( list ) {
					list = [];
				}
				return this;
			},

			// Disable .fire and .add
			// Abort any current/pending executions
			// Clear all callbacks and values
			disable: function() {
				locked = queue = [];
				list = memory = "";
				return this;
			},
			disabled: function() {
				return !list;
			},

			// Disable .fire
			// Also disable .add unless we have memory (since it would have no effect)
			// Abort any pending executions
			lock: function() {
				locked = queue = [];
				if ( !memory && !firing ) {
					list = memory = "";
				}
				return this;
			},
			locked: function() {
				return !!locked;
			},

			// Call all callbacks with the given context and arguments
			fireWith: function( context, args ) {
				if ( !locked ) {
					args = args || [];
					args = [ context, args.slice ? args.slice() : args ];
					queue.push( args );
					if ( !firing ) {
						fire();
					}
				}
				return this;
			},

			// Call all the callbacks with the given arguments
			fire: function() {
				self.fireWith( this, arguments );
				return this;
			},

			// To know if the callbacks have already been called at least once
			fired: function() {
				return !!fired;
			}
		};

	return self;
};


function Identity( v ) {
	return v;
}
function Thrower( ex ) {
	throw ex;
}

function adoptValue( value, resolve, reject, noValue ) {
	var method;

	try {

		if ( value && isFunction( ( method = value.promise ) ) ) {
			method.call( value ).done( resolve ).fail( reject );

		} else if ( value && isFunction( ( method = value.then ) ) ) {
			method.call( value, resolve, reject );

		} else {
			resolve.apply( undefined, [ value ].slice( noValue ) );
		}
	} catch ( value ) {
		reject.apply( undefined, [ value ] );
	}
}

jQuery.extend( {

	Deferred: function( func ) {
		var tuples = [

				// action, add listener, callbacks,
				// ... .then handlers, argument index, [final state]
				[ "notify", "progress", jQuery.Callbacks( "memory" ),
					jQuery.Callbacks( "memory" ), 2 ],
				[ "resolve", "done", jQuery.Callbacks( "once memory" ),
					jQuery.Callbacks( "once memory" ), 0, "resolved" ],
				[ "reject", "fail", jQuery.Callbacks( "once memory" ),
					jQuery.Callbacks( "once memory" ), 1, "rejected" ]
			],
			state = "pending",
			promise = {
				state: function() {
					return state;
				},
				always: function() {
					deferred.done( arguments ).fail( arguments );
					return this;
				},
				"catch": function( fn ) {
					return promise.then( null, fn );
				},

				pipe: function( /* fnDone, fnFail, fnProgress */ ) {
					var fns = arguments;

					return jQuery.Deferred( function( newDefer ) {
						jQuery.each( tuples, function( _i, tuple ) {

							// Map tuples (progress, done, fail) to arguments (done, fail, progress)
							var fn = isFunction( fns[ tuple[ 4 ] ] ) && fns[ tuple[ 4 ] ];

							deferred[ tuple[ 1 ] ]( function() {
								var returned = fn && fn.apply( this, arguments );
								if ( returned && isFunction( returned.promise ) ) {
									returned.promise()
										.progress( newDefer.notify )
										.done( newDefer.resolve )
										.fail( newDefer.reject );
								} else {
									newDefer[ tuple[ 0 ] + "With" ](
										this,
										fn ? [ returned ] : arguments
									);
								}
							} );
						} );
						fns = null;
					} ).promise();
				},
				then: function( onFulfilled, onRejected, onProgress ) {
					var maxDepth = 0;
					function resolve( depth, deferred, handler, special ) {
						return function() {
							var that = this,
								args = arguments,
								mightThrow = function() {
									var returned, then;

									if ( depth < maxDepth ) {
										return;
									}

									returned = handler.apply( that, args );


									if ( returned === deferred.promise() ) {
										throw new TypeError( "Thenable self-resolution" );
									}

									then = returned &&

										( typeof returned === "object" ||
											typeof returned === "function" ) &&
										returned.then;

									if ( isFunction( then ) ) {

										if ( special ) {
											then.call(
												returned,
												resolve( maxDepth, deferred, Identity, special ),
												resolve( maxDepth, deferred, Thrower, special )
											);

										// Normal processors (resolve) also hook into progress
										} else {

											// ...and disregard older resolution values
											maxDepth++;

											then.call(
												returned,
												resolve( maxDepth, deferred, Identity, special ),
												resolve( maxDepth, deferred, Thrower, special ),
												resolve( maxDepth, deferred, Identity,
													deferred.notifyWith )
											);
										}

									// Handle all other returned values
									} else {

										// Only substitute handlers pass on context
										// and multiple values (non-spec behavior)
										if ( handler !== Identity ) {
											that = undefined;
											args = [ returned ];
										}

										// Process the value(s)
										// Default process is resolve
										( special || deferred.resolveWith )( that, args );
									}
								},

								// Only normal processors (resolve) catch and reject exceptions
								process = special ?
									mightThrow :
									function() {
										try {
											mightThrow();
										} catch ( e ) {

											if ( jQuery.Deferred.exceptionHook ) {
												jQuery.Deferred.exceptionHook( e,
													process.stackTrace );
											}

											// Support: Promises/A+ section 2.3.3.3.4.1
											// https://promisesaplus.com/#point-61
											// Ignore post-resolution exceptions
											if ( depth + 1 >= maxDepth ) {

												// Only substitute handlers pass on context
												// and multiple values (non-spec behavior)
												if ( handler !== Thrower ) {
													that = undefined;
													args = [ e ];
												}

												deferred.rejectWith( that, args );
											}
										}
									};

							if ( depth ) {
								process();
							} else {

								// Call an optional hook to record the stack, in case of exception
								// since it's otherwise lost when execution goes async
								if ( jQuery.Deferred.getStackHook ) {
									process.stackTrace = jQuery.Deferred.getStackHook();
								}
								window.setTimeout( process );
							}
						};
					}

					return jQuery.Deferred( function( newDefer ) {

						// progress_handlers.add( ... )
						tuples[ 0 ][ 3 ].add(
							resolve(
								0,
								newDefer,
								isFunction( onProgress ) ?
									onProgress :
									Identity,
								newDefer.notifyWith
							)
						);

						// fulfilled_handlers.add( ... )
						tuples[ 1 ][ 3 ].add(
							resolve(
								0,
								newDefer,
								isFunction( onFulfilled ) ?
									onFulfilled :
									Identity
							)
						);

						// rejected_handlers.add( ... )
						tuples[ 2 ][ 3 ].add(
							resolve(
								0,
								newDefer,
								isFunction( onRejected ) ?
									onRejected :
									Thrower
							)
						);
					} ).promise();
				},

				// Get a promise for this deferred
				// If obj is provided, the promise aspect is added to the object
				promise: function( obj ) {
					return obj != null ? jQuery.extend( obj, promise ) : promise;
				}
			},
			deferred = {};

		// Add list-specific methods
		jQuery.each( tuples, function( i, tuple ) {
			var list = tuple[ 2 ],
				stateString = tuple[ 5 ];

			promise[ tuple[ 1 ] ] = list.add;

			if ( stateString ) {
				list.add(
					function() {
						state = stateString;
					},

					tuples[ 3 - i ][ 2 ].disable,
					tuples[ 3 - i ][ 3 ].disable,

					tuples[ 0 ][ 2 ].lock,

					tuples[ 0 ][ 3 ].lock
				);
			}
			list.add( tuple[ 3 ].fire );


			deferred[ tuple[ 0 ] ] = function() {
				deferred[ tuple[ 0 ] + "With" ]( this === deferred ? undefined : this, arguments );
				return this;
			};

			deferred[ tuple[ 0 ] + "With" ] = list.fireWith;
		} );

		// Make the deferred a promise
		promise.promise( deferred );

		// Call given func if any
		if ( func ) {
			func.call( deferred, deferred );
		}

		// All done!
		return deferred;
	},

	// Deferred helper
	when: function( singleValue ) {
		var

			// count of uncompleted subordinates
			remaining = arguments.length,

			// count of unprocessed arguments
			i = remaining,

			// subordinate fulfillment data
			resolveContexts = Array( i ),
			resolveValues = slice.call( arguments ),

			// the primary Deferred
			primary = jQuery.Deferred(),

			// subordinate callback factory
			updateFunc = function( i ) {
				return function( value ) {
					resolveContexts[ i ] = this;
					resolveValues[ i ] = arguments.length > 1 ? slice.call( arguments ) : value;
					if ( !( --remaining ) ) {
						primary.resolveWith( resolveContexts, resolveValues );
					}
				};
			};

		if ( remaining <= 1 ) {
			adoptValue( singleValue, primary.done( updateFunc( i ) ).resolve, primary.reject,
				!remaining );

			if ( primary.state() === "pending" ||
				isFunction( resolveValues[ i ] && resolveValues[ i ].then ) ) {

				return primary.then();
			}
		}

		while ( i-- ) {
			adoptValue( resolveValues[ i ], updateFunc( i ), primary.reject );
		}

		return primary.promise();
	}
} );

var rerrorNames = /^(Eval|Internal|Range|Reference|Syntax|Type|URI)Error$/;

jQuery.Deferred.exceptionHook = function( error, stack ) {
	if ( window.console && window.console.warn && error && rerrorNames.test( error.name ) ) {
		window.console.warn( "jQuery.Deferred exception: " + error.message, error.stack, stack );
	}
};

jQuery.readyException = function( error ) {
	window.setTimeout( function() {
		throw error;
	} );
};

var readyList = jQuery.Deferred();

jQuery.fn.ready = function( fn ) {

	readyList
		.then( fn )
		.catch( function( error ) {
			jQuery.readyException( error );
		} );

	return this;
};

jQuery.extend( {
	isReady: false,
	readyWait: 1,
	ready: function( wait ) {
		if ( wait === true ? --jQuery.readyWait : jQuery.isReady ) {
			return;
		}
		jQuery.isReady = true;

		if ( wait !== true && --jQuery.readyWait > 0 ) {
			return;
		}

		readyList.resolveWith( document, [ jQuery ] );
	}
} );

jQuery.ready.then = readyList.then;

// The ready event handler and self cleanup method
function completed() {
	document.removeEventListener( "DOMContentLoaded", completed );
	window.removeEventListener( "load", completed );
	jQuery.ready();
}

if ( document.readyState === "complete" ||
	( document.readyState !== "loading" && !document.documentElement.doScroll ) ) {

	window.setTimeout( jQuery.ready );

} else {

	document.addEventListener( "DOMContentLoaded", completed );

	window.addEventListener( "load", completed );
}


var access = function( elems, fn, key, value, chainable, emptyGet, raw ) {
	var i = 0,
		len = elems.length,
		bulk = key == null;

	// Sets many values
	if ( toType( key ) === "object" ) {
		chainable = true;
		for ( i in key ) {
			access( elems, fn, i, key[ i ], true, emptyGet, raw );
		}

	// Sets one value
	} else if ( value !== undefined ) {
		chainable = true;

		if ( !isFunction( value ) ) {
			raw = true;
		}

		if ( bulk ) {

			// Bulk operations run against the entire set
			if ( raw ) {
				fn.call( elems, value );
				fn = null;

			// ...except when executing function values
			} else {
				bulk = fn;
				fn = function( elem, _key, value ) {
					return bulk.call( jQuery( elem ), value );
				};
			}
		}

		if ( fn ) {
			for ( ; i < len; i++ ) {
				fn(
					elems[ i ], key, raw ?
						value :
						value.call( elems[ i ], i, fn( elems[ i ], key ) )
				);
			}
		}
	}

	if ( chainable ) {
		return elems;
	}

	// Gets
	if ( bulk ) {
		return fn.call( elems );
	}

	return len ? fn( elems[ 0 ], key ) : emptyGet;
};


var rmsPrefix = /^-ms-/,
	rdashAlpha = /-([a-z])/g;

function fcamelCase( _all, letter ) {
	return letter.toUpperCase();
}

function camelCase( string ) {
	return string.replace( rmsPrefix, "ms-" ).replace( rdashAlpha, fcamelCase );
}
var acceptData = function( owner ) {

	// Accepts only:
	//  - Node
	//    - Node.ELEMENT_NODE
	//    - Node.DOCUMENT_NODE
	//  - Object
	//    - Any
	return owner.nodeType === 1 || owner.nodeType === 9 || !( +owner.nodeType );
};




function Data() {
	this.expando = jQuery.expando + Data.uid++;
}

Data.uid = 1;

Data.prototype = {

	cache: function( owner ) {

		var value = owner[ this.expando ];

		if ( !value ) {
			value = {};
			if ( acceptData( owner ) ) {
				if ( owner.nodeType ) {
					owner[ this.expando ] = value;
				} else {
					Object.defineProperty( owner, this.expando, {
						value: value,
						configurable: true
					} );
				}
			}
		}

		return value;
	},
	set: function( owner, data, value ) {
		var prop,
			cache = this.cache( owner );

		if ( typeof data === "string" ) {
			cache[ camelCase( data ) ] = value;

		} else {

			for ( prop in data ) {
				cache[ camelCase( prop ) ] = data[ prop ];
			}
		}
		return cache;
	},
	get: function( owner, key ) {
		return key === undefined ?
			this.cache( owner ) :

			// Always use camelCase key (gh-2257)
			owner[ this.expando ] && owner[ this.expando ][ camelCase( key ) ];
	},
	access: function( owner, key, value ) {
		if ( key === undefined ||
				( ( key && typeof key === "string" ) && value === undefined ) ) {

			return this.get( owner, key );
		}

		this.set( owner, key, value );
		return value !== undefined ? value : key;
	},
	remove: function( owner, key ) {
		var i,
			cache = owner[ this.expando ];

		if ( cache === undefined ) {
			return;
		}

		if ( key !== undefined ) {

			// Support array or space separated string of keys
			if ( Array.isArray( key ) ) {

				// If key is an array of keys...
				// We always set camelCase keys, so remove that.
				key = key.map( camelCase );
			} else {
				key = camelCase( key );

				// If a key with the spaces exists, use it.
				// Otherwise, create an array by matching non-whitespace
				key = key in cache ?
					[ key ] :
					( key.match( rnothtmlwhite ) || [] );
			}

			i = key.length;

			while ( i-- ) {
				delete cache[ key[ i ] ];
			}
		}

		if ( key === undefined || jQuery.isEmptyObject( cache ) ) {
			if ( owner.nodeType ) {
				owner[ this.expando ] = undefined;
			} else {
				delete owner[ this.expando ];
			}
		}
	},
	hasData: function( owner ) {
		var cache = owner[ this.expando ];
		return cache !== undefined && !jQuery.isEmptyObject( cache );
	}
};
var dataPriv = new Data();

var dataUser = new Data();

var rbrace = /^(?:\{[\w\W]*\}|\[[\w\W]*\])$/,
	rmultiDash = /[A-Z]/g;

function getData( data ) {
	if ( data === "true" ) {
		return true;
	}

	if ( data === "false" ) {
		return false;
	}

	if ( data === "null" ) {
		return null;
	}

	if ( data === +data + "" ) {
		return +data;
	}

	if ( rbrace.test( data ) ) {
		return JSON.parse( data );
	}

	return data;
}

function dataAttr( elem, key, data ) {
	var name;
	if ( data === undefined && elem.nodeType === 1 ) {
		name = "data-" + key.replace( rmultiDash, "-$&" ).toLowerCase();
		data = elem.getAttribute( name );

		if ( typeof data === "string" ) {
			try {
				data = getData( data );
			} catch ( e ) {}

			// Make sure we set the data so it isn't changed later
			dataUser.set( elem, key, data );
		} else {
			data = undefined;
		}
	}
	return data;
}

jQuery.extend( {
	hasData: function( elem ) {
		return dataUser.hasData( elem ) || dataPriv.hasData( elem );
	},

	data: function( elem, name, data ) {
		return dataUser.access( elem, name, data );
	},

	removeData: function( elem, name ) {
		dataUser.remove( elem, name );
	},

	_data: function( elem, name, data ) {
		return dataPriv.access( elem, name, data );
	},

	_removeData: function( elem, name ) {
		dataPriv.remove( elem, name );
	}
} );

jQuery.fn.extend( {
	data: function( key, value ) {
		var i, name, data,
			elem = this[ 0 ],
			attrs = elem && elem.attributes;

		// Gets all values
		if ( key === undefined ) {
			if ( this.length ) {
				data = dataUser.get( elem );

				if ( elem.nodeType === 1 && !dataPriv.get( elem, "hasDataAttrs" ) ) {
					i = attrs.length;
					while ( i-- ) {

						// Support: IE 11 only
						// The attrs elements can be null (#14894)
						if ( attrs[ i ] ) {
							name = attrs[ i ].name;
							if ( name.indexOf( "data-" ) === 0 ) {
								name = camelCase( name.slice( 5 ) );
								dataAttr( elem, name, data[ name ] );
							}
						}
					}
					dataPriv.set( elem, "hasDataAttrs", true );
				}
			}

			return data;
		}

		// Sets multiple values
		if ( typeof key === "object" ) {
			return this.each( function() {
				dataUser.set( this, key );
			} );
		}

		return access( this, function( value ) {
			var data;

			if ( elem && value === undefined ) {

				data = dataUser.get( elem, key );
				if ( data !== undefined ) {
					return data;
				}

				data = dataAttr( elem, key );
				if ( data !== undefined ) {
					return data;
				}

				// We tried really hard, but the data doesn't exist.
				return;
			}

			// Set the data...
			this.each( function() {

				// We always store the camelCased key
				dataUser.set( this, key, value );
			} );
		}, null, value, arguments.length > 1, null, true );
	},

	removeData: function( key ) {
		return this.each( function() {
			dataUser.remove( this, key );
		} );
	}
} );


jQuery.extend( {
	queue: function( elem, type, data ) {
		var queue;

		if ( elem ) {
			type = ( type || "fx" ) + "queue";
			queue = dataPriv.get( elem, type );

			if ( data ) {
				if ( !queue || Array.isArray( data ) ) {
					queue = dataPriv.access( elem, type, jQuery.makeArray( data ) );
				} else {
					queue.push( data );
				}
			}
			return queue || [];
		}
	},

	dequeue: function( elem, type ) {
		type = type || "fx";

		var queue = jQuery.queue( elem, type ),
			startLength = queue.length,
			fn = queue.shift(),
			hooks = jQuery._queueHooks( elem, type ),
			next = function() {
				jQuery.dequeue( elem, type );
			};

		if ( fn === "inprogress" ) {
			fn = queue.shift();
			startLength--;
		}

		if ( fn ) {
			if ( type === "fx" ) {
				queue.unshift( "inprogress" );
			}

			delete hooks.stop;
			fn.call( elem, next, hooks );
		}

		if ( !startLength && hooks ) {
			hooks.empty.fire();
		}
	},

	_queueHooks: function( elem, type ) {
		var key = type + "queueHooks";
		return dataPriv.get( elem, key ) || dataPriv.access( elem, key, {
			empty: jQuery.Callbacks( "once memory" ).add( function() {
				dataPriv.remove( elem, [ type + "queue", key ] );
			} )
		} );
	}
} );

jQuery.fn.extend( {
	queue: function( type, data ) {
		var setter = 2;

		if ( typeof type !== "string" ) {
			data = type;
			type = "fx";
			setter--;
		}

		if ( arguments.length < setter ) {
			return jQuery.queue( this[ 0 ], type );
		}

		return data === undefined ?
			this :
			this.each( function() {
				var queue = jQuery.queue( this, type, data );

				// Ensure a hooks for this queue
				jQuery._queueHooks( this, type );

				if ( type === "fx" && queue[ 0 ] !== "inprogress" ) {
					jQuery.dequeue( this, type );
				}
			} );
	},
	dequeue: function( type ) {
		return this.each( function() {
			jQuery.dequeue( this, type );
		} );
	},
	clearQueue: function( type ) {
		return this.queue( type || "fx", [] );
	},

	promise: function( type, obj ) {
		var tmp,
			count = 1,
			defer = jQuery.Deferred(),
			elements = this,
			i = this.length,
			resolve = function() {
				if ( !( --count ) ) {
					defer.resolveWith( elements, [ elements ] );
				}
			};

		if ( typeof type !== "string" ) {
			obj = type;
			type = undefined;
		}
		type = type || "fx";

		while ( i-- ) {
			tmp = dataPriv.get( elements[ i ], type + "queueHooks" );
			if ( tmp && tmp.empty ) {
				count++;
				tmp.empty.add( resolve );
			}
		}
		resolve();
		return defer.promise( obj );
	}
} );
var pnum = ( /[+-]?(?:\d*\.|)\d+(?:[eE][+-]?\d+|)/ ).source;

var rcssNum = new RegExp( "^(?:([+-])=|)(" + pnum + ")([a-z%]*)$", "i" );


var cssExpand = [ "Top", "Right", "Bottom", "Left" ];

var documentElement = document.documentElement;



	var isAttached = function( elem ) {
			return jQuery.contains( elem.ownerDocument, elem );
		},
		composed = { composed: true };

	if ( documentElement.getRootNode ) {
		isAttached = function( elem ) {
			return jQuery.contains( elem.ownerDocument, elem ) ||
				elem.getRootNode( composed ) === elem.ownerDocument;
		};
	}
var isHiddenWithinTree = function( elem, el ) {

		elem = el || elem;

		// Inline style trumps all
		return elem.style.display === "none" ||
			elem.style.display === "" &&

			// Otherwise, check computed style
			// Support: Firefox <=43 - 45
			// Disconnected elements can have computed display: none, so first confirm that elem is
			// in the document.
			isAttached( elem ) &&

			jQuery.css( elem, "display" ) === "none";
	};



function adjustCSS( elem, prop, valueParts, tween ) {
	var adjusted, scale,
		maxIterations = 20,
		currentValue = tween ?
			function() {
				return tween.cur();
			} :
			function() {
				return jQuery.css( elem, prop, "" );
			},
		initial = currentValue(),
		unit = valueParts && valueParts[ 3 ] || ( jQuery.cssNumber[ prop ] ? "" : "px" ),

		// Starting value computation is required for potential unit mismatches
		initialInUnit = elem.nodeType &&
			( jQuery.cssNumber[ prop ] || unit !== "px" && +initial ) &&
			rcssNum.exec( jQuery.css( elem, prop ) );

	if ( initialInUnit && initialInUnit[ 3 ] !== unit ) {

		// Support: Firefox <=54
		// Halve the iteration target value to prevent interference from CSS upper bounds (gh-2144)
		initial = initial / 2;

		// Trust units reported by jQuery.css
		unit = unit || initialInUnit[ 3 ];

		// Iteratively approximate from a nonzero starting point
		initialInUnit = +initial || 1;

		while ( maxIterations-- ) {

			// Evaluate and update our best guess (doubling guesses that zero out).
			// Finish if the scale equals or crosses 1 (making the old*new product non-positive).
			jQuery.style( elem, prop, initialInUnit + unit );
			if ( ( 1 - scale ) * ( 1 - ( scale = currentValue() / initial || 0.5 ) ) <= 0 ) {
				maxIterations = 0;
			}
			initialInUnit = initialInUnit / scale;

		}

		initialInUnit = initialInUnit * 2;
		jQuery.style( elem, prop, initialInUnit + unit );

		// Make sure we update the tween properties later on
		valueParts = valueParts || [];
	}

	if ( valueParts ) {
		initialInUnit = +initialInUnit || +initial || 0;

		// Apply relative offset (+=/-=) if specified
		adjusted = valueParts[ 1 ] ?
			initialInUnit + ( valueParts[ 1 ] + 1 ) * valueParts[ 2 ] :
			+valueParts[ 2 ];
		if ( tween ) {
			tween.unit = unit;
			tween.start = initialInUnit;
			tween.end = adjusted;
		}
	}
	return adjusted;
}


var defaultDisplayMap = {};

function getDefaultDisplay( elem ) {
	var temp,
		doc = elem.ownerDocument,
		nodeName = elem.nodeName,
		display = defaultDisplayMap[ nodeName ];

	if ( display ) {
		return display;
	}

	temp = doc.body.appendChild( doc.createElement( nodeName ) );
	display = jQuery.css( temp, "display" );

	temp.parentNode.removeChild( temp );

	if ( display === "none" ) {
		display = "block";
	}
	defaultDisplayMap[ nodeName ] = display;

	return display;
}

function showHide( elements, show ) {
	var display, elem,
		values = [],
		index = 0,
		length = elements.length;

	// Determine new display value for elements that need to change
	for ( ; index < length; index++ ) {
		elem = elements[ index ];
		if ( !elem.style ) {
			continue;
		}

		display = elem.style.display;
		if ( show ) {
			if ( display === "none" ) {
				values[ index ] = dataPriv.get( elem, "display" ) || null;
				if ( !values[ index ] ) {
					elem.style.display = "";
				}
			}
			if ( elem.style.display === "" && isHiddenWithinTree( elem ) ) {
				values[ index ] = getDefaultDisplay( elem );
			}
		} else {
			if ( display !== "none" ) {
				values[ index ] = "none";

				// Remember what we're overwriting
				dataPriv.set( elem, "display", display );
			}
		}
	}

	// Set the display of the elements in a second loop to avoid constant reflow
	for ( index = 0; index < length; index++ ) {
		if ( values[ index ] != null ) {
			elements[ index ].style.display = values[ index ];
		}
	}

	return elements;
}

jQuery.fn.extend( {
	show: function() {
		return showHide( this, true );
	},
	hide: function() {
		return showHide( this );
	},
	toggle: function( state ) {
		if ( typeof state === "boolean" ) {
			return state ? this.show() : this.hide();
		}

		return this.each( function() {
			if ( isHiddenWithinTree( this ) ) {
				jQuery( this ).show();
			} else {
				jQuery( this ).hide();
			}
		} );
	}
} );
var rcheckableType = ( /^(?:checkbox|radio)$/i );

var rtagName = ( /<([a-z][^\/\0>\x20\t\r\n\f]*)/i );

var rscriptType = ( /^$|^module$|\/(?:java|ecma)script/i );

( function() {
	var fragment = document.createDocumentFragment(),
		div = fragment.appendChild( document.createElement( "div" ) ),
		input = document.createElement( "input" );

	input.setAttribute( "type", "radio" );
	input.setAttribute( "checked", "checked" );
	input.setAttribute( "name", "t" );

	div.appendChild( input );
	support.checkClone = div.cloneNode( true ).cloneNode( true ).lastChild.checked;
	div.innerHTML = "<textarea>x</textarea>";
	support.noCloneChecked = !!div.cloneNode( true ).lastChild.defaultValue;
	div.innerHTML = "<option></option>";
	support.option = !!div.lastChild;
} )();


var wrapMap = {
	thead: [ 1, "<table>", "</table>" ],
	col: [ 2, "<table><colgroup>", "</colgroup></table>" ],
	tr: [ 2, "<table><tbody>", "</tbody></table>" ],
	td: [ 3, "<table><tbody><tr>", "</tr></tbody></table>" ],

	_default: [ 0, "", "" ]
};

wrapMap.tbody = wrapMap.tfoot = wrapMap.colgroup = wrapMap.caption = wrapMap.thead;
wrapMap.th = wrapMap.td;

// Support: IE <=9 only
if ( !support.option ) {
	wrapMap.optgroup = wrapMap.option = [ 1, "<select multiple='multiple'>", "</select>" ];
}


function getAll( context, tag ) {

	// Support: IE <=9 - 11 only
	// Use typeof to avoid zero-argument method invocation on host objects (#15151)
	var ret;

	if ( typeof context.getElementsByTagName !== "undefined" ) {
		ret = context.getElementsByTagName( tag || "*" );

	} else if ( typeof context.querySelectorAll !== "undefined" ) {
		ret = context.querySelectorAll( tag || "*" );

	} else {
		ret = [];
	}

	if ( tag === undefined || tag && nodeName( context, tag ) ) {
		return jQuery.merge( [ context ], ret );
	}

	return ret;
}


// Mark scripts as having already been evaluated
function setGlobalEval( elems, refElements ) {
	var i = 0,
		l = elems.length;

	for ( ; i < l; i++ ) {
		dataPriv.set(
			elems[ i ],
			"globalEval",
			!refElements || dataPriv.get( refElements[ i ], "globalEval" )
		);
	}
}


var rhtml = /<|&#?\w+;/;

function buildFragment( elems, context, scripts, selection, ignored ) {
	var elem, tmp, tag, wrap, attached, j,
		fragment = context.createDocumentFragment(),
		nodes = [],
		i = 0,
		l = elems.length;

	for ( ; i < l; i++ ) {
		elem = elems[ i ];

		if ( elem || elem === 0 ) {

			// Add nodes directly
			if ( toType( elem ) === "object" ) {

				// Support: Android <=4.0 only, PhantomJS 1 only
				// push.apply(_, arraylike) throws on ancient WebKit
				jQuery.merge( nodes, elem.nodeType ? [ elem ] : elem );

			// Convert non-html into a text node
			} else if ( !rhtml.test( elem ) ) {
				nodes.push( context.createTextNode( elem ) );

			// Convert html into DOM nodes
			} else {
				tmp = tmp || fragment.appendChild( context.createElement( "div" ) );

				// Deserialize a standard representation
				tag = ( rtagName.exec( elem ) || [ "", "" ] )[ 1 ].toLowerCase();
				wrap = wrapMap[ tag ] || wrapMap._default;
				tmp.innerHTML = wrap[ 1 ] + jQuery.htmlPrefilter( elem ) + wrap[ 2 ];

				// Descend through wrappers to the right content
				j = wrap[ 0 ];
				while ( j-- ) {
					tmp = tmp.lastChild;
				}

				// Support: Android <=4.0 only, PhantomJS 1 only
				// push.apply(_, arraylike) throws on ancient WebKit
				jQuery.merge( nodes, tmp.childNodes );

				// Remember the top-level container
				tmp = fragment.firstChild;

				tmp.textContent = "";
			}
		}
	}

	fragment.textContent = "";

	i = 0;
	while ( ( elem = nodes[ i++ ] ) ) {

		if ( selection && jQuery.inArray( elem, selection ) > -1 ) {
			if ( ignored ) {
				ignored.push( elem );
			}
			continue;
		}

		attached = isAttached( elem );

		// Append to fragment
		tmp = getAll( fragment.appendChild( elem ), "script" );

		// Preserve script evaluation history
		if ( attached ) {
			setGlobalEval( tmp );
		}

		// Capture executables
		if ( scripts ) {
			j = 0;
			while ( ( elem = tmp[ j++ ] ) ) {
				if ( rscriptType.test( elem.type || "" ) ) {
					scripts.push( elem );
				}
			}
		}
	}

	return fragment;
}


var rtypenamespace = /^([^.]*)(?:\.(.+)|)/;

function returnTrue() {
	return true;
}

function returnFalse() {
	return false;
}

function expectSync( elem, type ) {
	return ( elem === safeActiveElement() ) === ( type === "focus" );
}


function safeActiveElement() {
	try {
		return document.activeElement;
	} catch ( err ) { }
}

function on( elem, types, selector, data, fn, one ) {
	var origFn, type;

	// Types can be a map of types/handlers
	if ( typeof types === "object" ) {

		// ( types-Object, selector, data )
		if ( typeof selector !== "string" ) {

			// ( types-Object, data )
			data = data || selector;
			selector = undefined;
		}
		for ( type in types ) {
			on( elem, type, selector, data, types[ type ], one );
		}
		return elem;
	}

	if ( data == null && fn == null ) {

		// ( types, fn )
		fn = selector;
		data = selector = undefined;
	} else if ( fn == null ) {
		if ( typeof selector === "string" ) {

			// ( types, selector, fn )
			fn = data;
			data = undefined;
		} else {

			// ( types, data, fn )
			fn = data;
			data = selector;
			selector = undefined;
		}
	}
	if ( fn === false ) {
		fn = returnFalse;
	} else if ( !fn ) {
		return elem;
	}

	if ( one === 1 ) {
		origFn = fn;
		fn = function( event ) {

			jQuery().off( event );
			return origFn.apply( this, arguments );
		};

		fn.guid = origFn.guid || ( origFn.guid = jQuery.guid++ );
	}
	return elem.each( function() {
		jQuery.event.add( this, types, fn, data, selector );
	} );
}

jQuery.event = {

	global: {},

	add: function( elem, types, handler, data, selector ) {

		var handleObjIn, eventHandle, tmp,
			events, t, handleObj,
			special, handlers, type, namespaces, origType,
			elemData = dataPriv.get( elem );

		if ( !acceptData( elem ) ) {
			return;
		}

		if ( handler.handler ) {
			handleObjIn = handler;
			handler = handleObjIn.handler;
			selector = handleObjIn.selector;
		}

		if ( selector ) {
			jQuery.find.matchesSelector( documentElement, selector );
		}

		// Make sure that the handler has a unique ID, used to find/remove it later
		if ( !handler.guid ) {
			handler.guid = jQuery.guid++;
		}

		// Init the element's event structure and main handler, if this is the first
		if ( !( events = elemData.events ) ) {
			events = elemData.events = Object.create( null );
		}
		if ( !( eventHandle = elemData.handle ) ) {
			eventHandle = elemData.handle = function( e ) {

				// Discard the second event of a jQuery.event.trigger() and
				// when an event is called after a page has unloaded
				return typeof jQuery !== "undefined" && jQuery.event.triggered !== e.type ?
					jQuery.event.dispatch.apply( elem, arguments ) : undefined;
			};
		}

		// Handle multiple events separated by a space
		types = ( types || "" ).match( rnothtmlwhite ) || [ "" ];
		t = types.length;
		while ( t-- ) {
			tmp = rtypenamespace.exec( types[ t ] ) || [];
			type = origType = tmp[ 1 ];
			namespaces = ( tmp[ 2 ] || "" ).split( "." ).sort();

			// There *must* be a type, no attaching namespace-only handlers
			if ( !type ) {
				continue;
			}

			// If event changes its type, use the special event handlers for the changed type
			special = jQuery.event.special[ type ] || {};

			// If selector defined, determine special event api type, otherwise given type
			type = ( selector ? special.delegateType : special.bindType ) || type;

			// Update special based on newly reset type
			special = jQuery.event.special[ type ] || {};

			// handleObj is passed to all event handlers
			handleObj = jQuery.extend( {
				type: type,
				origType: origType,
				data: data,
				handler: handler,
				guid: handler.guid,
				selector: selector,
				needsContext: selector && jQuery.expr.match.needsContext.test( selector ),
				namespace: namespaces.join( "." )
			}, handleObjIn );

			// Init the event handler queue if we're the first
			if ( !( handlers = events[ type ] ) ) {
				handlers = events[ type ] = [];
				handlers.delegateCount = 0;

				// Only use addEventListener if the special events handler returns false
				if ( !special.setup ||
					special.setup.call( elem, data, namespaces, eventHandle ) === false ) {

					if ( elem.addEventListener ) {
						elem.addEventListener( type, eventHandle );
					}
				}
			}

			if ( special.add ) {
				special.add.call( elem, handleObj );

				if ( !handleObj.handler.guid ) {
					handleObj.handler.guid = handler.guid;
				}
			}

			if ( selector ) {
				handlers.splice( handlers.delegateCount++, 0, handleObj );
			} else {
				handlers.push( handleObj );
			}

			jQuery.event.global[ type ] = true;
		}

	},

	remove: function( elem, types, handler, selector, mappedTypes ) {

		var j, origCount, tmp,
			events, t, handleObj,
			special, handlers, type, namespaces, origType,
			elemData = dataPriv.hasData( elem ) && dataPriv.get( elem );

		if ( !elemData || !( events = elemData.events ) ) {
			return;
		}

		// Once for each type.namespace in types; type may be omitted
		types = ( types || "" ).match( rnothtmlwhite ) || [ "" ];
		t = types.length;
		while ( t-- ) {
			tmp = rtypenamespace.exec( types[ t ] ) || [];
			type = origType = tmp[ 1 ];
			namespaces = ( tmp[ 2 ] || "" ).split( "." ).sort();

			// Unbind all events (on this namespace, if provided) for the element
			if ( !type ) {
				for ( type in events ) {
					jQuery.event.remove( elem, type + types[ t ], handler, selector, true );
				}
				continue;
			}

			special = jQuery.event.special[ type ] || {};
			type = ( selector ? special.delegateType : special.bindType ) || type;
			handlers = events[ type ] || [];
			tmp = tmp[ 2 ] &&
				new RegExp( "(^|\\.)" + namespaces.join( "\\.(?:.*\\.|)" ) + "(\\.|$)" );

			origCount = j = handlers.length;
			while ( j-- ) {
				handleObj = handlers[ j ];

				if ( ( mappedTypes || origType === handleObj.origType ) &&
					( !handler || handler.guid === handleObj.guid ) &&
					( !tmp || tmp.test( handleObj.namespace ) ) &&
					( !selector || selector === handleObj.selector ||
						selector === "**" && handleObj.selector ) ) {
					handlers.splice( j, 1 );

					if ( handleObj.selector ) {
						handlers.delegateCount--;
					}
					if ( special.remove ) {
						special.remove.call( elem, handleObj );
					}
				}
			}

			if ( origCount && !handlers.length ) {
				if ( !special.teardown ||
					special.teardown.call( elem, namespaces, elemData.handle ) === false ) {

					jQuery.removeEvent( elem, type, elemData.handle );
				}

				delete events[ type ];
			}
		}

		if ( jQuery.isEmptyObject( events ) ) {
			dataPriv.remove( elem, "handle events" );
		}
	},

	dispatch: function( nativeEvent ) {

		var i, j, ret, matched, handleObj, handlerQueue,
			args = new Array( arguments.length ),

			// Make a writable jQuery.Event from the native event object
			event = jQuery.event.fix( nativeEvent ),

			handlers = (
				dataPriv.get( this, "events" ) || Object.create( null )
			)[ event.type ] || [],
			special = jQuery.event.special[ event.type ] || {};

		// Use the fix-ed jQuery.Event rather than the (read-only) native event
		args[ 0 ] = event;

		for ( i = 1; i < arguments.length; i++ ) {
			args[ i ] = arguments[ i ];
		}

		event.delegateTarget = this;

		if ( special.preDispatch && special.preDispatch.call( this, event ) === false ) {
			return;
		}

		handlerQueue = jQuery.event.handlers.call( this, event, handlers );

		i = 0;
		while ( ( matched = handlerQueue[ i++ ] ) && !event.isPropagationStopped() ) {
			event.currentTarget = matched.elem;

			j = 0;
			while ( ( handleObj = matched.handlers[ j++ ] ) &&
				!event.isImmediatePropagationStopped() ) {

				if ( !event.rnamespace || handleObj.namespace === false ||
					event.rnamespace.test( handleObj.namespace ) ) {

					event.handleObj = handleObj;
					event.data = handleObj.data;

					ret = ( ( jQuery.event.special[ handleObj.origType ] || {} ).handle ||
						handleObj.handler ).apply( matched.elem, args );

					if ( ret !== undefined ) {
						if ( ( event.result = ret ) === false ) {
							event.preventDefault();
							event.stopPropagation();
						}
					}
				}
			}
		}

		// Call the postDispatch hook for the mapped type
		if ( special.postDispatch ) {
			special.postDispatch.call( this, event );
		}

		return event.result;
	},

	handlers: function( event, handlers ) {
		var i, handleObj, sel, matchedHandlers, matchedSelectors,
			handlerQueue = [],
			delegateCount = handlers.delegateCount,
			cur = event.target;

		// Find delegate handlers
		if ( delegateCount &&

			// Support: IE <=9
			// Black-hole SVG <use> instance trees (trac-13180)
			cur.nodeType &&

			// Support: Firefox <=42
			// Suppress spec-violating clicks indicating a non-primary pointer button (trac-3861)
			// https://www.w3.org/TR/DOM-Level-3-Events/#event-type-click
			// Support: IE 11 only
			// ...but not arrow key "clicks" of radio inputs, which can have `button` -1 (gh-2343)
			!( event.type === "click" && event.button >= 1 ) ) {

			for ( ; cur !== this; cur = cur.parentNode || this ) {

				// Don't check non-elements (#13208)
				// Don't process clicks on disabled elements (#6911, #8165, #11382, #11764)
				if ( cur.nodeType === 1 && !( event.type === "click" && cur.disabled === true ) ) {
					matchedHandlers = [];
					matchedSelectors = {};
					for ( i = 0; i < delegateCount; i++ ) {
						handleObj = handlers[ i ];

						// Don't conflict with Object.prototype properties (#13203)
						sel = handleObj.selector + " ";

						if ( matchedSelectors[ sel ] === undefined ) {
							matchedSelectors[ sel ] = handleObj.needsContext ?
								jQuery( sel, this ).index( cur ) > -1 :
								jQuery.find( sel, this, null, [ cur ] ).length;
						}
						if ( matchedSelectors[ sel ] ) {
							matchedHandlers.push( handleObj );
						}
					}
					if ( matchedHandlers.length ) {
						handlerQueue.push( { elem: cur, handlers: matchedHandlers } );
					}
				}
			}
		}

		// Add the remaining (directly-bound) handlers
		cur = this;
		if ( delegateCount < handlers.length ) {
			handlerQueue.push( { elem: cur, handlers: handlers.slice( delegateCount ) } );
		}

		return handlerQueue;
	},

	addProp: function( name, hook ) {
		Object.defineProperty( jQuery.Event.prototype, name, {
			enumerable: true,
			configurable: true,

			get: isFunction( hook ) ?
				function() {
					if ( this.originalEvent ) {
						return hook( this.originalEvent );
					}
				} :
				function() {
					if ( this.originalEvent ) {
						return this.originalEvent[ name ];
					}
				},

			set: function( value ) {
				Object.defineProperty( this, name, {
					enumerable: true,
					configurable: true,
					writable: true,
					value: value
				} );
			}
		} );
	},

	fix: function( originalEvent ) {
		return originalEvent[ jQuery.expando ] ?
			originalEvent :
			new jQuery.Event( originalEvent );
	},

	special: {
		load: {

			noBubble: true
		},
		click: {

			// Utilize native event to ensure correct state for checkable inputs
			setup: function( data ) {

				var el = this || data;

				// Claim the first handler
				if ( rcheckableType.test( el.type ) &&
					el.click && nodeName( el, "input" ) ) {

					leverageNative( el, "click", returnTrue );
				}

				return false;
			},
			trigger: function( data ) {

				var el = this || data;

				if ( rcheckableType.test( el.type ) &&
					el.click && nodeName( el, "input" ) ) {

					leverageNative( el, "click" );
				}

				return true;
			},

			_default: function( event ) {
				var target = event.target;
				return rcheckableType.test( target.type ) &&
					target.click && nodeName( target, "input" ) &&
					dataPriv.get( target, "click" ) ||
					nodeName( target, "a" );
			}
		}
	}
};

function leverageNative( el, type, expectSync ) {

	if ( !expectSync ) {
		if ( dataPriv.get( el, type ) === undefined ) {
			jQuery.event.add( el, type, returnTrue );
		}
		return;
	}

	dataPriv.set( el, type, false );
	jQuery.event.add( el, type, {
		namespace: false,
		handler: function( event ) {
			var notAsync, result,
				saved = dataPriv.get( this, type );

			if ( ( event.isTrigger & 1 ) && this[ type ] ) {

				if ( !saved.length ) {

					saved = slice.call( arguments );
					dataPriv.set( this, type, saved );

					notAsync = expectSync( this, type );
					this[ type ]();
					result = dataPriv.get( this, type );
					if ( saved !== result || notAsync ) {
						dataPriv.set( this, type, false );
					} else {
						result = {};
					}
					if ( saved !== result ) {

						event.stopImmediatePropagation();
						event.preventDefault();

						return result && result.value;
					}

				} else if ( ( jQuery.event.special[ type ] || {} ).delegateType ) {
					event.stopPropagation();
				}

			} else if ( saved.length ) {

				dataPriv.set( this, type, {
					value: jQuery.event.trigger(

						jQuery.extend( saved[ 0 ], jQuery.Event.prototype ),
						saved.slice( 1 ),
						this
					)
				} );

				event.stopImmediatePropagation();
			}
		}
	} );
}

jQuery.removeEvent = function( elem, type, handle ) {

	if ( elem.removeEventListener ) {
		elem.removeEventListener( type, handle );
	}
};

jQuery.Event = function( src, props ) {

	if ( !( this instanceof jQuery.Event ) ) {
		return new jQuery.Event( src, props );
	}

	if ( src && src.type ) {
		this.originalEvent = src;
		this.type = src.type;

		this.isDefaultPrevented = src.defaultPrevented ||
				src.defaultPrevented === undefined &&

				src.returnValue === false ?
			returnTrue :
			returnFalse;

		this.target = ( src.target && src.target.nodeType === 3 ) ?
			src.target.parentNode :
			src.target;

		this.currentTarget = src.currentTarget;
		this.relatedTarget = src.relatedTarget;

	} else {
		this.type = src;
	}

	if ( props ) {
		jQuery.extend( this, props );
	}

	this.timeStamp = src && src.timeStamp || Date.now();

	this[ jQuery.expando ] = true;
};


jQuery.Event.prototype = {
	constructor: jQuery.Event,
	isDefaultPrevented: returnFalse,
	isPropagationStopped: returnFalse,
	isImmediatePropagationStopped: returnFalse,
	isSimulated: false,

	preventDefault: function() {
		var e = this.originalEvent;

		this.isDefaultPrevented = returnTrue;

		if ( e && !this.isSimulated ) {
			e.preventDefault();
		}
	},
	stopPropagation: function() {
		var e = this.originalEvent;

		this.isPropagationStopped = returnTrue;

		if ( e && !this.isSimulated ) {
			e.stopPropagation();
		}
	},
	stopImmediatePropagation: function() {
		var e = this.originalEvent;

		this.isImmediatePropagationStopped = returnTrue;

		if ( e && !this.isSimulated ) {
			e.stopImmediatePropagation();
		}

		this.stopPropagation();
	}
};

jQuery.each( {
	altKey: true,
	bubbles: true,
	cancelable: true,
	changedTouches: true,
	ctrlKey: true,
	detail: true,
	eventPhase: true,
	metaKey: true,
	pageX: true,
	pageY: true,
	shiftKey: true,
	view: true,
	"char": true,
	code: true,
	charCode: true,
	key: true,
	keyCode: true,
	button: true,
	buttons: true,
	clientX: true,
	clientY: true,
	offsetX: true,
	offsetY: true,
	pointerId: true,
	pointerType: true,
	screenX: true,
	screenY: true,
	targetTouches: true,
	toElement: true,
	touches: true,
	which: true
}, jQuery.event.addProp );

jQuery.each( { focus: "focusin", blur: "focusout" }, function( type, delegateType ) {
	jQuery.event.special[ type ] = {

		setup: function() {


			leverageNative( this, type, expectSync );

			return false;
		},
		trigger: function() {

			leverageNative( this, type );

			return true;
		},

		_default: function() {
			return true;
		},

		delegateType: delegateType
	};
} );

jQuery.each( {
	mouseenter: "mouseover",
	mouseleave: "mouseout",
	pointerenter: "pointerover",
	pointerleave: "pointerout"
}, function( orig, fix ) {
	jQuery.event.special[ orig ] = {
		delegateType: fix,
		bindType: fix,

		handle: function( event ) {
			var ret,
				target = this,
				related = event.relatedTarget,
				handleObj = event.handleObj;

			if ( !related || ( related !== target && !jQuery.contains( target, related ) ) ) {
				event.type = handleObj.origType;
				ret = handleObj.handler.apply( this, arguments );
				event.type = fix;
			}
			return ret;
		}
	};
} );

jQuery.fn.extend( {

	on: function( types, selector, data, fn ) {
		return on( this, types, selector, data, fn );
	},
	one: function( types, selector, data, fn ) {
		return on( this, types, selector, data, fn, 1 );
	},
	off: function( types, selector, fn ) {
		var handleObj, type;
		if ( types && types.preventDefault && types.handleObj ) {

			handleObj = types.handleObj;
			jQuery( types.delegateTarget ).off(
				handleObj.namespace ?
					handleObj.origType + "." + handleObj.namespace :
					handleObj.origType,
				handleObj.selector,
				handleObj.handler
			);
			return this;
		}
		if ( typeof types === "object" ) {

			for ( type in types ) {
				this.off( type, selector, types[ type ] );
			}
			return this;
		}
		if ( selector === false || typeof selector === "function" ) {

			fn = selector;
			selector = undefined;
		}
		if ( fn === false ) {
			fn = returnFalse;
		}
		return this.each( function() {
			jQuery.event.remove( this, types, fn, selector );
		} );
	}
} );


var

	rnoInnerhtml = /<script|<style|<link/i,

	rchecked = /checked\s*(?:[^=]|=\s*.checked.)/i,
	rcleanScript = /^\s*<!(?:\[CDATA\[|--)|(?:\]\]|--)>\s*$/g;

function manipulationTarget( elem, content ) {
	if ( nodeName( elem, "table" ) &&
		nodeName( content.nodeType !== 11 ? content : content.firstChild, "tr" ) ) {

		return jQuery( elem ).children( "tbody" )[ 0 ] || elem;
	}

	return elem;
}

function disableScript( elem ) {
	elem.type = ( elem.getAttribute( "type" ) !== null ) + "/" + elem.type;
	return elem;
}
function restoreScript( elem ) {
	if ( ( elem.type || "" ).slice( 0, 5 ) === "true/" ) {
		elem.type = elem.type.slice( 5 );
	} else {
		elem.removeAttribute( "type" );
	}

	return elem;
}

function cloneCopyEvent( src, dest ) {
	var i, l, type, pdataOld, udataOld, udataCur, events;

	if ( dest.nodeType !== 1 ) {
		return;
	}

	// 1. Copy private data: events, handlers, etc.
	if ( dataPriv.hasData( src ) ) {
		pdataOld = dataPriv.get( src );
		events = pdataOld.events;

		if ( events ) {
			dataPriv.remove( dest, "handle events" );

			for ( type in events ) {
				for ( i = 0, l = events[ type ].length; i < l; i++ ) {
					jQuery.event.add( dest, type, events[ type ][ i ] );
				}
			}
		}
	}

	if ( dataUser.hasData( src ) ) {
		udataOld = dataUser.access( src );
		udataCur = jQuery.extend( {}, udataOld );

		dataUser.set( dest, udataCur );
	}
}

function fixInput( src, dest ) {
	var nodeName = dest.nodeName.toLowerCase();

	if ( nodeName === "input" && rcheckableType.test( src.type ) ) {
		dest.checked = src.checked;
	} else if ( nodeName === "input" || nodeName === "textarea" ) {
		dest.defaultValue = src.defaultValue;
	}
}

function domManip( collection, args, callback, ignored ) {

	args = flat( args );

	var fragment, first, scripts, hasScripts, node, doc,
		i = 0,
		l = collection.length,
		iNoClone = l - 1,
		value = args[ 0 ],
		valueIsFunction = isFunction( value );

	if ( valueIsFunction ||
			( l > 1 && typeof value === "string" &&
				!support.checkClone && rchecked.test( value ) ) ) {
		return collection.each( function( index ) {
			var self = collection.eq( index );
			if ( valueIsFunction ) {
				args[ 0 ] = value.call( this, index, self.html() );
			}
			domManip( self, args, callback, ignored );
		} );
	}

	if ( l ) {
		fragment = buildFragment( args, collection[ 0 ].ownerDocument, false, collection, ignored );
		first = fragment.firstChild;

		if ( fragment.childNodes.length === 1 ) {
			fragment = first;
		}

		if ( first || ignored ) {
			scripts = jQuery.map( getAll( fragment, "script" ), disableScript );
			hasScripts = scripts.length;
			for ( ; i < l; i++ ) {
				node = fragment;

				if ( i !== iNoClone ) {
					node = jQuery.clone( node, true, true );

					// Keep references to cloned scripts for later restoration
					if ( hasScripts ) {
						jQuery.merge( scripts, getAll( node, "script" ) );
					}
				}

				callback.call( collection[ i ], node, i );
			}

			if ( hasScripts ) {
				doc = scripts[ scripts.length - 1 ].ownerDocument;

				jQuery.map( scripts, restoreScript );

				for ( i = 0; i < hasScripts; i++ ) {
					node = scripts[ i ];
					if ( rscriptType.test( node.type || "" ) &&
						!dataPriv.access( node, "globalEval" ) &&
						jQuery.contains( doc, node ) ) {

						if ( node.src && ( node.type || "" ).toLowerCase()  !== "module" ) {

							if ( jQuery._evalUrl && !node.noModule ) {
								jQuery._evalUrl( node.src, {
									nonce: node.nonce || node.getAttribute( "nonce" )
								}, doc );
							}
						} else {
							DOMEval( node.textContent.replace( rcleanScript, "" ), node, doc );
						}
					}
				}
			}
		}
	}

	return collection;
}

function remove( elem, selector, keepData ) {
	var node,
		nodes = selector ? jQuery.filter( selector, elem ) : elem,
		i = 0;

	for ( ; ( node = nodes[ i ] ) != null; i++ ) {
		if ( !keepData && node.nodeType === 1 ) {
			jQuery.cleanData( getAll( node ) );
		}

		if ( node.parentNode ) {
			if ( keepData && isAttached( node ) ) {
				setGlobalEval( getAll( node, "script" ) );
			}
			node.parentNode.removeChild( node );
		}
	}

	return elem;
}

jQuery.extend( {
	htmlPrefilter: function( html ) {
		return html;
	},

	clone: function( elem, dataAndEvents, deepDataAndEvents ) {
		var i, l, srcElements, destElements,
			clone = elem.cloneNode( true ),
			inPage = isAttached( elem );

		if ( !support.noCloneChecked && ( elem.nodeType === 1 || elem.nodeType === 11 ) &&
				!jQuery.isXMLDoc( elem ) ) {

			destElements = getAll( clone );
			srcElements = getAll( elem );

			for ( i = 0, l = srcElements.length; i < l; i++ ) {
				fixInput( srcElements[ i ], destElements[ i ] );
			}
		}

		if ( dataAndEvents ) {
			if ( deepDataAndEvents ) {
				srcElements = srcElements || getAll( elem );
				destElements = destElements || getAll( clone );

				for ( i = 0, l = srcElements.length; i < l; i++ ) {
					cloneCopyEvent( srcElements[ i ], destElements[ i ] );
				}
			} else {
				cloneCopyEvent( elem, clone );
			}
		}

		destElements = getAll( clone, "script" );
		if ( destElements.length > 0 ) {
			setGlobalEval( destElements, !inPage && getAll( elem, "script" ) );
		}

		return clone;
	},

	cleanData: function( elems ) {
		var data, elem, type,
			special = jQuery.event.special,
			i = 0;

		for ( ; ( elem = elems[ i ] ) !== undefined; i++ ) {
			if ( acceptData( elem ) ) {
				if ( ( data = elem[ dataPriv.expando ] ) ) {
					if ( data.events ) {
						for ( type in data.events ) {
							if ( special[ type ] ) {
								jQuery.event.remove( elem, type );

							// This is a shortcut to avoid jQuery.event.remove's overhead
							} else {
								jQuery.removeEvent( elem, type, data.handle );
							}
						}
					}
					elem[ dataPriv.expando ] = undefined;
				}
				if ( elem[ dataUser.expando ] ) {
					elem[ dataUser.expando ] = undefined;
				}
			}
		}
	}
} );

jQuery.fn.extend( {
	detach: function( selector ) {
		return remove( this, selector, true );
	},

	remove: function( selector ) {
		return remove( this, selector );
	},

	text: function( value ) {
		return access( this, function( value ) {
			return value === undefined ?
				jQuery.text( this ) :
				this.empty().each( function() {
					if ( this.nodeType === 1 || this.nodeType === 11 || this.nodeType === 9 ) {
						this.textContent = value;
					}
				} );
		}, null, value, arguments.length );
	},

	append: function() {
		return domManip( this, arguments, function( elem ) {
			if ( this.nodeType === 1 || this.nodeType === 11 || this.nodeType === 9 ) {
				var target = manipulationTarget( this, elem );
				target.appendChild( elem );
			}
		} );
	},

	prepend: function() {
		return domManip( this, arguments, function( elem ) {
			if ( this.nodeType === 1 || this.nodeType === 11 || this.nodeType === 9 ) {
				var target = manipulationTarget( this, elem );
				target.insertBefore( elem, target.firstChild );
			}
		} );
	},

	before: function() {
		return domManip( this, arguments, function( elem ) {
			if ( this.parentNode ) {
				this.parentNode.insertBefore( elem, this );
			}
		} );
	},

	after: function() {
		return domManip( this, arguments, function( elem ) {
			if ( this.parentNode ) {
				this.parentNode.insertBefore( elem, this.nextSibling );
			}
		} );
	},

	empty: function() {
		var elem,
			i = 0;

		for ( ; ( elem = this[ i ] ) != null; i++ ) {
			if ( elem.nodeType === 1 ) {

				jQuery.cleanData( getAll( elem, false ) );

				elem.textContent = "";
			}
		}

		return this;
	},

	clone: function( dataAndEvents, deepDataAndEvents ) {
		dataAndEvents = dataAndEvents == null ? false : dataAndEvents;
		deepDataAndEvents = deepDataAndEvents == null ? dataAndEvents : deepDataAndEvents;

		return this.map( function() {
			return jQuery.clone( this, dataAndEvents, deepDataAndEvents );
		} );
	},

	html: function( value ) {
		return access( this, function( value ) {
			var elem = this[ 0 ] || {},
				i = 0,
				l = this.length;

			if ( value === undefined && elem.nodeType === 1 ) {
				return elem.innerHTML;
			}

			if ( typeof value === "string" && !rnoInnerhtml.test( value ) &&
				!wrapMap[ ( rtagName.exec( value ) || [ "", "" ] )[ 1 ].toLowerCase() ] ) {

				value = jQuery.htmlPrefilter( value );

				try {
					for ( ; i < l; i++ ) {
						elem = this[ i ] || {};

						if ( elem.nodeType === 1 ) {
							jQuery.cleanData( getAll( elem, false ) );
							elem.innerHTML = value;
						}
					}

					elem = 0;

				} catch ( e ) {}
			}

			if ( elem ) {
				this.empty().append( value );
			}
		}, null, value, arguments.length );
	},

	replaceWith: function() {
		var ignored = [];

		return domManip( this, arguments, function( elem ) {
			var parent = this.parentNode;

			if ( jQuery.inArray( this, ignored ) < 0 ) {
				jQuery.cleanData( getAll( this ) );
				if ( parent ) {
					parent.replaceChild( elem, this );
				}
			}
		}, ignored );
	}
} );

jQuery.each( {
	appendTo: "append",
	prependTo: "prepend",
	insertBefore: "before",
	insertAfter: "after",
	replaceAll: "replaceWith"
}, function( name, original ) {
	jQuery.fn[ name ] = function( selector ) {
		var elems,
			ret = [],
			insert = jQuery( selector ),
			last = insert.length - 1,
			i = 0;

		for ( ; i <= last; i++ ) {
			elems = i === last ? this : this.clone( true );
			jQuery( insert[ i ] )[ original ]( elems );
			push.apply( ret, elems.get() );
		}

		return this.pushStack( ret );
	};
} );
var rnumnonpx = new RegExp( "^(" + pnum + ")(?!px)[a-z%]+$", "i" );

var getStyles = function( elem ) {
		var view = elem.ownerDocument.defaultView;
		if ( !view || !view.opener ) {
			view = window;
		}
		return view.getComputedStyle( elem );
	};

var swap = function( elem, options, callback ) {
	var ret, name,
		old = {};

	for ( name in options ) {
		old[ name ] = elem.style[ name ];
		elem.style[ name ] = options[ name ];
	}

	ret = callback.call( elem );

	for ( name in options ) {
		elem.style[ name ] = old[ name ];
	}

	return ret;
};


var rboxStyle = new RegExp( cssExpand.join( "|" ), "i" );



( function() {

	function computeStyleTests() {

		if ( !div ) {
			return;
		}

		container.style.cssText = "position:absolute;left:-11111px;width:60px;" +
			"margin-top:1px;padding:0;border:0";
		div.style.cssText =
			"position:relative;display:block;box-sizing:border-box;overflow:scroll;" +
			"margin:auto;border:1px;padding:1px;" +
			"width:60%;top:1%";
		documentElement.appendChild( container ).appendChild( div );

		var divStyle = window.getComputedStyle( div );
		pixelPositionVal = divStyle.top !== "1%";

		reliableMarginLeftVal = roundPixelMeasures( divStyle.marginLeft ) === 12;
		div.style.right = "60%";
		pixelBoxStylesVal = roundPixelMeasures( divStyle.right ) === 36;
		boxSizingReliableVal = roundPixelMeasures( divStyle.width ) === 36;
		div.style.position = "absolute";
		scrollboxSizeVal = roundPixelMeasures( div.offsetWidth / 3 ) === 12;
		documentElement.removeChild( container );
		div = null;
	}

	function roundPixelMeasures( measure ) {
		return Math.round( parseFloat( measure ) );
	}

	var pixelPositionVal, boxSizingReliableVal, scrollboxSizeVal, pixelBoxStylesVal,
		reliableTrDimensionsVal, reliableMarginLeftVal,
		container = document.createElement( "div" ),
		div = document.createElement( "div" );

	if ( !div.style ) {
		return;
	}
	div.style.backgroundClip = "content-box";
	div.cloneNode( true ).style.backgroundClip = "";
	support.clearCloneStyle = div.style.backgroundClip === "content-box";

	jQuery.extend( support, {
		boxSizingReliable: function() {
			computeStyleTests();
			return boxSizingReliableVal;
		},
		pixelBoxStyles: function() {
			computeStyleTests();
			return pixelBoxStylesVal;
		},
		pixelPosition: function() {
			computeStyleTests();
			return pixelPositionVal;
		},
		reliableMarginLeft: function() {
			computeStyleTests();
			return reliableMarginLeftVal;
		},
		scrollboxSize: function() {
			computeStyleTests();
			return scrollboxSizeVal;
		},
		reliableTrDimensions: function() {
			var table, tr, trChild, trStyle;
			if ( reliableTrDimensionsVal == null ) {
				table = document.createElement( "table" );
				tr = document.createElement( "tr" );
				trChild = document.createElement( "div" );

				table.style.cssText = "position:absolute;left:-11111px;border-collapse:separate";
				tr.style.cssText = "border:1px solid";
				tr.style.height = "1px";
				trChild.style.height = "9px";
				trChild.style.display = "block";

				documentElement
					.appendChild( table )
					.appendChild( tr )
					.appendChild( trChild );

				trStyle = window.getComputedStyle( tr );
				reliableTrDimensionsVal = ( parseInt( trStyle.height, 10 ) +
					parseInt( trStyle.borderTopWidth, 10 ) +
					parseInt( trStyle.borderBottomWidth, 10 ) ) === tr.offsetHeight;

				documentElement.removeChild( table );
			}
			return reliableTrDimensionsVal;
		}
	} );
} )();


function curCSS( elem, name, computed ) {
	var width, minWidth, maxWidth, ret,

		style = elem.style;

	computed = computed || getStyles( elem );
	if ( computed ) {
		ret = computed.getPropertyValue( name ) || computed[ name ];

		if ( ret === "" && !isAttached( elem ) ) {
			ret = jQuery.style( elem, name );
		}

		if ( !support.pixelBoxStyles() && rnumnonpx.test( ret ) && rboxStyle.test( name ) ) {

			width = style.width;
			minWidth = style.minWidth;
			maxWidth = style.maxWidth;

			style.minWidth = style.maxWidth = style.width = ret;
			ret = computed.width;

			style.width = width;
			style.minWidth = minWidth;
			style.maxWidth = maxWidth;
		}
	}

	return ret !== undefined ?

		ret + "" :
		ret;
}


function addGetHookIf( conditionFn, hookFn ) {

	return {
		get: function() {
			if ( conditionFn() ) {
				delete this.get;
				return;
			}
			return ( this.get = hookFn ).apply( this, arguments );
		}
	};
}


var cssPrefixes = [ "Webkit", "Moz", "ms" ],
	emptyStyle = document.createElement( "div" ).style,
	vendorProps = {};

function vendorPropName( name ) {

	var capName = name[ 0 ].toUpperCase() + name.slice( 1 ),
		i = cssPrefixes.length;

	while ( i-- ) {
		name = cssPrefixes[ i ] + capName;
		if ( name in emptyStyle ) {
			return name;
		}
	}
}

function finalPropName( name ) {
	var final = jQuery.cssProps[ name ] || vendorProps[ name ];

	if ( final ) {
		return final;
	}
	if ( name in emptyStyle ) {
		return name;
	}
	return vendorProps[ name ] = vendorPropName( name ) || name;
}


var

	rdisplayswap = /^(none|table(?!-c[ea]).+)/,
	rcustomProp = /^--/,
	cssShow = { position: "absolute", visibility: "hidden", display: "block" },
	cssNormalTransform = {
		letterSpacing: "0",
		fontWeight: "400"
	};

function setPositiveNumber( _elem, value, subtract ) {

	var matches = rcssNum.exec( value );
	return matches ?

		Math.max( 0, matches[ 2 ] - ( subtract || 0 ) ) + ( matches[ 3 ] || "px" ) :
		value;
}

function boxModelAdjustment( elem, dimension, box, isBorderBox, styles, computedVal ) {
	var i = dimension === "width" ? 1 : 0,
		extra = 0,
		delta = 0;

	if ( box === ( isBorderBox ? "border" : "content" ) ) {
		return 0;
	}

	for ( ; i < 4; i += 2 ) {

		if ( box === "margin" ) {
			delta += jQuery.css( elem, box + cssExpand[ i ], true, styles );
		}

		if ( !isBorderBox ) {

			delta += jQuery.css( elem, "padding" + cssExpand[ i ], true, styles );

			if ( box !== "padding" ) {
				delta += jQuery.css( elem, "border" + cssExpand[ i ] + "Width", true, styles );

			} else {
				extra += jQuery.css( elem, "border" + cssExpand[ i ] + "Width", true, styles );
			}
		} else {

			if ( box === "content" ) {
				delta -= jQuery.css( elem, "padding" + cssExpand[ i ], true, styles );
			}

			if ( box !== "margin" ) {
				delta -= jQuery.css( elem, "border" + cssExpand[ i ] + "Width", true, styles );
			}
		}
	}

	if ( !isBorderBox && computedVal >= 0 ) {

		delta += Math.max( 0, Math.ceil(
			elem[ "offset" + dimension[ 0 ].toUpperCase() + dimension.slice( 1 ) ] -
			computedVal -
			delta -
			extra -
			0.5
		) ) || 0;
	}

	return delta;
}

function getWidthOrHeight( elem, dimension, extra ) {
	var styles = getStyles( elem ),
		boxSizingNeeded = !support.boxSizingReliable() || extra,
		isBorderBox = boxSizingNeeded &&
			jQuery.css( elem, "boxSizing", false, styles ) === "border-box",
		valueIsBorderBox = isBorderBox,

		val = curCSS( elem, dimension, styles ),
		offsetProp = "offset" + dimension[ 0 ].toUpperCase() + dimension.slice( 1 );

	if ( rnumnonpx.test( val ) ) {
		if ( !extra ) {
			return val;
		}
		val = "auto";
	}

	if ( ( !support.boxSizingReliable() && isBorderBox ||

		!support.reliableTrDimensions() && nodeName( elem, "tr" ) ||

		val === "auto" ||

		!parseFloat( val ) && jQuery.css( elem, "display", false, styles ) === "inline" ) &&

		elem.getClientRects().length ) {

		isBorderBox = jQuery.css( elem, "boxSizing", false, styles ) === "border-box";

		valueIsBorderBox = offsetProp in elem;
		if ( valueIsBorderBox ) {
			val = elem[ offsetProp ];
		}
	}

	val = parseFloat( val ) || 0;

	return ( val +
		boxModelAdjustment(
			elem,
			dimension,
			extra || ( isBorderBox ? "border" : "content" ),
			valueIsBorderBox,
			styles,

			val
		)
	) + "px";
}

jQuery.extend( {
	cssHooks: {
		opacity: {
			get: function( elem, computed ) {
				if ( computed ) {

					var ret = curCSS( elem, "opacity" );
					return ret === "" ? "1" : ret;
				}
			}
		}
	},

	cssNumber: {
		"animationIterationCount": true,
		"columnCount": true,
		"fillOpacity": true,
		"flexGrow": true,
		"flexShrink": true,
		"fontWeight": true,
		"gridArea": true,
		"gridColumn": true,
		"gridColumnEnd": true,
		"gridColumnStart": true,
		"gridRow": true,
		"gridRowEnd": true,
		"gridRowStart": true,
		"lineHeight": true,
		"opacity": true,
		"order": true,
		"orphans": true,
		"widows": true,
		"zIndex": true,
		"zoom": true
	},

	cssProps: {},

	style: function( elem, name, value, extra ) {

		if ( !elem || elem.nodeType === 3 || elem.nodeType === 8 || !elem.style ) {
			return;
		}

		var ret, type, hooks,
			origName = camelCase( name ),
			isCustomProp = rcustomProp.test( name ),
			style = elem.style;

		if ( !isCustomProp ) {
			name = finalPropName( origName );
		}

		hooks = jQuery.cssHooks[ name ] || jQuery.cssHooks[ origName ];

		if ( value !== undefined ) {
			type = typeof value;

			if ( type === "string" && ( ret = rcssNum.exec( value ) ) && ret[ 1 ] ) {
				value = adjustCSS( elem, name, ret );
				type = "number";
			}

			if ( value == null || value !== value ) {
				return;
			}

			if ( type === "number" && !isCustomProp ) {
				value += ret && ret[ 3 ] || ( jQuery.cssNumber[ origName ] ? "" : "px" );
			}

			if ( !support.clearCloneStyle && value === "" && name.indexOf( "background" ) === 0 ) {
				style[ name ] = "inherit";
			}

			if ( !hooks || !( "set" in hooks ) ||
				( value = hooks.set( elem, value, extra ) ) !== undefined ) {

				if ( isCustomProp ) {
					style.setProperty( name, value );
				} else {
					style[ name ] = value;
				}
			}

		} else {

			if ( hooks && "get" in hooks &&
				( ret = hooks.get( elem, false, extra ) ) !== undefined ) {

				return ret;
			}

			return style[ name ];
		}
	},

	css: function( elem, name, extra, styles ) {
		var val, num, hooks,
			origName = camelCase( name ),
			isCustomProp = rcustomProp.test( name );

		if ( !isCustomProp ) {
			name = finalPropName( origName );
		}

		hooks = jQuery.cssHooks[ name ] || jQuery.cssHooks[ origName ];

		if ( hooks && "get" in hooks ) {
			val = hooks.get( elem, true, extra );
		}

		if ( val === undefined ) {
			val = curCSS( elem, name, styles );
		}

		if ( val === "normal" && name in cssNormalTransform ) {
			val = cssNormalTransform[ name ];
		}

		if ( extra === "" || extra ) {
			num = parseFloat( val );
			return extra === true || isFinite( num ) ? num || 0 : val;
		}

		return val;
	}
} );

jQuery.each( [ "height", "width" ], function( _i, dimension ) {
	jQuery.cssHooks[ dimension ] = {
		get: function( elem, computed, extra ) {
			if ( computed ) {
				return rdisplayswap.test( jQuery.css( elem, "display" ) ) &&
					( !elem.getClientRects().length || !elem.getBoundingClientRect().width ) ?
					swap( elem, cssShow, function() {
						return getWidthOrHeight( elem, dimension, extra );
					} ) :
					getWidthOrHeight( elem, dimension, extra );
			}
		},

		set: function( elem, value, extra ) {
			var matches,
				styles = getStyles( elem ),
				scrollboxSizeBuggy = !support.scrollboxSize() &&
					styles.position === "absolute",

				boxSizingNeeded = scrollboxSizeBuggy || extra,
				isBorderBox = boxSizingNeeded &&
					jQuery.css( elem, "boxSizing", false, styles ) === "border-box",
				subtract = extra ?
					boxModelAdjustment(
						elem,
						dimension,
						extra,
						isBorderBox,
						styles
					) :
					0;
			if ( isBorderBox && scrollboxSizeBuggy ) {
				subtract -= Math.ceil(
					elem[ "offset" + dimension[ 0 ].toUpperCase() + dimension.slice( 1 ) ] -
					parseFloat( styles[ dimension ] ) -
					boxModelAdjustment( elem, dimension, "border", false, styles ) -
					0.5
				);
			}

			if ( subtract && ( matches = rcssNum.exec( value ) ) &&
				( matches[ 3 ] || "px" ) !== "px" ) {

				elem.style[ dimension ] = value;
				value = jQuery.css( elem, dimension );
			}

			return setPositiveNumber( elem, value, subtract );
		}
	};
} );

jQuery.cssHooks.marginLeft = addGetHookIf( support.reliableMarginLeft,
	function( elem, computed ) {
		if ( computed ) {
			return ( parseFloat( curCSS( elem, "marginLeft" ) ) ||
				elem.getBoundingClientRect().left -
					swap( elem, { marginLeft: 0 }, function() {
						return elem.getBoundingClientRect().left;
					} )
			) + "px";
		}
	}
);

jQuery.each( {
	margin: "",
	padding: "",
	border: "Width"
}, function( prefix, suffix ) {
	jQuery.cssHooks[ prefix + suffix ] = {
		expand: function( value ) {
			var i = 0,
				expanded = {},
				parts = typeof value === "string" ? value.split( " " ) : [ value ];

			for ( ; i < 4; i++ ) {
				expanded[ prefix + cssExpand[ i ] + suffix ] =
					parts[ i ] || parts[ i - 2 ] || parts[ 0 ];
			}

			return expanded;
		}
	};

	if ( prefix !== "margin" ) {
		jQuery.cssHooks[ prefix + suffix ].set = setPositiveNumber;
	}
} );

jQuery.fn.extend( {
	css: function( name, value ) {
		return access( this, function( elem, name, value ) {
			var styles, len,
				map = {},
				i = 0;

			if ( Array.isArray( name ) ) {
				styles = getStyles( elem );
				len = name.length;

				for ( ; i < len; i++ ) {
					map[ name[ i ] ] = jQuery.css( elem, name[ i ], false, styles );
				}

				return map;
			}

			return value !== undefined ?
				jQuery.style( elem, name, value ) :
				jQuery.css( elem, name );
		}, name, value, arguments.length > 1 );
	}
} );


function Tween( elem, options, prop, end, easing ) {
	return new Tween.prototype.init( elem, options, prop, end, easing );
}
jQuery.Tween = Tween;

Tween.prototype = {
	constructor: Tween,
	init: function( elem, options, prop, end, easing, unit ) {
		this.elem = elem;
		this.prop = prop;
		this.easing = easing || jQuery.easing._default;
		this.options = options;
		this.start = this.now = this.cur();
		this.end = end;
		this.unit = unit || ( jQuery.cssNumber[ prop ] ? "" : "px" );
	},
	cur: function() {
		var hooks = Tween.propHooks[ this.prop ];

		return hooks && hooks.get ?
			hooks.get( this ) :
			Tween.propHooks._default.get( this );
	},
	run: function( percent ) {
		var eased,
			hooks = Tween.propHooks[ this.prop ];

		if ( this.options.duration ) {
			this.pos = eased = jQuery.easing[ this.easing ](
				percent, this.options.duration * percent, 0, 1, this.options.duration
			);
		} else {
			this.pos = eased = percent;
		}
		this.now = ( this.end - this.start ) * eased + this.start;

		if ( this.options.step ) {
			this.options.step.call( this.elem, this.now, this );
		}

		if ( hooks && hooks.set ) {
			hooks.set( this );
		} else {
			Tween.propHooks._default.set( this );
		}
		return this;
	}
};

Tween.prototype.init.prototype = Tween.prototype;

Tween.propHooks = {
	_default: {
		get: function( tween ) {
			var result;

			if ( tween.elem.nodeType !== 1 ||
				tween.elem[ tween.prop ] != null && tween.elem.style[ tween.prop ] == null ) {
				return tween.elem[ tween.prop ];
			}
			result = jQuery.css( tween.elem, tween.prop, "" );
			return !result || result === "auto" ? 0 : result;
		},
		set: function( tween ) {
			if ( jQuery.fx.step[ tween.prop ] ) {
				jQuery.fx.step[ tween.prop ]( tween );
			} else if ( tween.elem.nodeType === 1 && (
				jQuery.cssHooks[ tween.prop ] ||
					tween.elem.style[ finalPropName( tween.prop ) ] != null ) ) {
				jQuery.style( tween.elem, tween.prop, tween.now + tween.unit );
			} else {
				tween.elem[ tween.prop ] = tween.now;
			}
		}
	}
};

Tween.propHooks.scrollTop = Tween.propHooks.scrollLeft = {
	set: function( tween ) {
		if ( tween.elem.nodeType && tween.elem.parentNode ) {
			tween.elem[ tween.prop ] = tween.now;
		}
	}
};

jQuery.easing = {
	linear: function( p ) {
		return p;
	},
	swing: function( p ) {
		return 0.5 - Math.cos( p * Math.PI ) / 2;
	},
	_default: "swing"
};

jQuery.fx = Tween.prototype.init;

jQuery.fx.step = {};




var
	fxNow, inProgress,
	rfxtypes = /^(?:toggle|show|hide)$/,
	rrun = /queueHooks$/;

function schedule() {
	if ( inProgress ) {
		if ( document.hidden === false && window.requestAnimationFrame ) {
			window.requestAnimationFrame( schedule );
		} else {
			window.setTimeout( schedule, jQuery.fx.interval );
		}

		jQuery.fx.tick();
	}
}

function createFxNow() {
	window.setTimeout( function() {
		fxNow = undefined;
	} );
	return ( fxNow = Date.now() );
}

function genFx( type, includeWidth ) {
	var which,
		i = 0,
		attrs = { height: type };

	includeWidth = includeWidth ? 1 : 0;
	for ( ; i < 4; i += 2 - includeWidth ) {
		which = cssExpand[ i ];
		attrs[ "margin" + which ] = attrs[ "padding" + which ] = type;
	}

	if ( includeWidth ) {
		attrs.opacity = attrs.width = type;
	}

	return attrs;
}

function createTween( value, prop, animation ) {
	var tween,
		collection = ( Animation.tweeners[ prop ] || [] ).concat( Animation.tweeners[ "*" ] ),
		index = 0,
		length = collection.length;
	for ( ; index < length; index++ ) {
		if ( ( tween = collection[ index ].call( animation, prop, value ) ) ) {

			return tween;
		}
	}
}

function defaultPrefilter( elem, props, opts ) {
	var prop, value, toggle, hooks, oldfire, propTween, restoreDisplay, display,
		isBox = "width" in props || "height" in props,
		anim = this,
		orig = {},
		style = elem.style,
		hidden = elem.nodeType && isHiddenWithinTree( elem ),
		dataShow = dataPriv.get( elem, "fxshow" );

	if ( !opts.queue ) {
		hooks = jQuery._queueHooks( elem, "fx" );
		if ( hooks.unqueued == null ) {
			hooks.unqueued = 0;
			oldfire = hooks.empty.fire;
			hooks.empty.fire = function() {
				if ( !hooks.unqueued ) {
					oldfire();
				}
			};
		}
		hooks.unqueued++;

		anim.always( function() {

			anim.always( function() {
				hooks.unqueued--;
				if ( !jQuery.queue( elem, "fx" ).length ) {
					hooks.empty.fire();
				}
			} );
		} );
	}

	for ( prop in props ) {
		value = props[ prop ];
		if ( rfxtypes.test( value ) ) {
			delete props[ prop ];
			toggle = toggle || value === "toggle";
			if ( value === ( hidden ? "hide" : "show" ) ) {

				if ( value === "show" && dataShow && dataShow[ prop ] !== undefined ) {
					hidden = true;

				} else {
					continue;
				}
			}
			orig[ prop ] = dataShow && dataShow[ prop ] || jQuery.style( elem, prop );
		}
	}

	propTween = !jQuery.isEmptyObject( props );
	if ( !propTween && jQuery.isEmptyObject( orig ) ) {
		return;
	}

	if ( isBox && elem.nodeType === 1 ) {
		opts.overflow = [ style.overflow, style.overflowX, style.overflowY ];

		restoreDisplay = dataShow && dataShow.display;
		if ( restoreDisplay == null ) {
			restoreDisplay = dataPriv.get( elem, "display" );
		}
		display = jQuery.css( elem, "display" );
		if ( display === "none" ) {
			if ( restoreDisplay ) {
				display = restoreDisplay;
			} else {

				showHide( [ elem ], true );
				restoreDisplay = elem.style.display || restoreDisplay;
				display = jQuery.css( elem, "display" );
				showHide( [ elem ] );
			}
		}

		if ( display === "inline" || display === "inline-block" && restoreDisplay != null ) {
			if ( jQuery.css( elem, "float" ) === "none" ) {
				if ( !propTween ) {
					anim.done( function() {
						style.display = restoreDisplay;
					} );
					if ( restoreDisplay == null ) {
						display = style.display;
						restoreDisplay = display === "none" ? "" : display;
					}
				}
				style.display = "inline-block";
			}
		}
	}

	if ( opts.overflow ) {
		style.overflow = "hidden";
		anim.always( function() {
			style.overflow = opts.overflow[ 0 ];
			style.overflowX = opts.overflow[ 1 ];
			style.overflowY = opts.overflow[ 2 ];
		} );
	}

	propTween = false;
	for ( prop in orig ) {

		if ( !propTween ) {
			if ( dataShow ) {
				if ( "hidden" in dataShow ) {
					hidden = dataShow.hidden;
				}
			} else {
				dataShow = dataPriv.access( elem, "fxshow", { display: restoreDisplay } );
			}

			if ( toggle ) {
				dataShow.hidden = !hidden;
			}

			if ( hidden ) {
				showHide( [ elem ], true );
			}

			anim.done( function() {

				if ( !hidden ) {
					showHide( [ elem ] );
				}
				dataPriv.remove( elem, "fxshow" );
				for ( prop in orig ) {
					jQuery.style( elem, prop, orig[ prop ] );
				}
			} );
		}

		propTween = createTween( hidden ? dataShow[ prop ] : 0, prop, anim );
		if ( !( prop in dataShow ) ) {
			dataShow[ prop ] = propTween.start;
			if ( hidden ) {
				propTween.end = propTween.start;
				propTween.start = 0;
			}
		}
	}
}

function propFilter( props, specialEasing ) {
	var index, name, easing, value, hooks;

	for ( index in props ) {
		name = camelCase( index );
		easing = specialEasing[ name ];
		value = props[ index ];
		if ( Array.isArray( value ) ) {
			easing = value[ 1 ];
			value = props[ index ] = value[ 0 ];
		}

		if ( index !== name ) {
			props[ name ] = value;
			delete props[ index ];
		}

		hooks = jQuery.cssHooks[ name ];
		if ( hooks && "expand" in hooks ) {
			value = hooks.expand( value );
			delete props[ name ];
			for ( index in value ) {
				if ( !( index in props ) ) {
					props[ index ] = value[ index ];
					specialEasing[ index ] = easing;
				}
			}
		} else {
			specialEasing[ name ] = easing;
		}
	}
}

function Animation( elem, properties, options ) {
	var result,
		stopped,
		index = 0,
		length = Animation.prefilters.length,
		deferred = jQuery.Deferred().always( function() {

			delete tick.elem;
		} ),
		tick = function() {
			if ( stopped ) {
				return false;
			}
			var currentTime = fxNow || createFxNow(),
				remaining = Math.max( 0, animation.startTime + animation.duration - currentTime ),

				temp = remaining / animation.duration || 0,
				percent = 1 - temp,
				index = 0,
				length = animation.tweens.length;

			for ( ; index < length; index++ ) {
				animation.tweens[ index ].run( percent );
			}

			deferred.notifyWith( elem, [ animation, percent, remaining ] );

			if ( percent < 1 && length ) {
				return remaining;
			}

			if ( !length ) {
				deferred.notifyWith( elem, [ animation, 1, 0 ] );
			}

			deferred.resolveWith( elem, [ animation ] );
			return false;
		},
		animation = deferred.promise( {
			elem: elem,
			props: jQuery.extend( {}, properties ),
			opts: jQuery.extend( true, {
				specialEasing: {},
				easing: jQuery.easing._default
			}, options ),
			originalProperties: properties,
			originalOptions: options,
			startTime: fxNow || createFxNow(),
			duration: options.duration,
			tweens: [],
			createTween: function( prop, end ) {
				var tween = jQuery.Tween( elem, animation.opts, prop, end,
					animation.opts.specialEasing[ prop ] || animation.opts.easing );
				animation.tweens.push( tween );
				return tween;
			},
			stop: function( gotoEnd ) {
				var index = 0,

					length = gotoEnd ? animation.tweens.length : 0;
				if ( stopped ) {
					return this;
				}
				stopped = true;
				for ( ; index < length; index++ ) {
					animation.tweens[ index ].run( 1 );
				}

				if ( gotoEnd ) {
					deferred.notifyWith( elem, [ animation, 1, 0 ] );
					deferred.resolveWith( elem, [ animation, gotoEnd ] );
				} else {
					deferred.rejectWith( elem, [ animation, gotoEnd ] );
				}
				return this;
			}
		} ),
		props = animation.props;

	propFilter( props, animation.opts.specialEasing );

	for ( ; index < length; index++ ) {
		result = Animation.prefilters[ index ].call( animation, elem, props, animation.opts );
		if ( result ) {
			if ( isFunction( result.stop ) ) {
				jQuery._queueHooks( animation.elem, animation.opts.queue ).stop =
					result.stop.bind( result );
			}
			return result;
		}
	}

	jQuery.map( props, createTween, animation );

	if ( isFunction( animation.opts.start ) ) {
		animation.opts.start.call( elem, animation );
	}

	animation
		.progress( animation.opts.progress )
		.done( animation.opts.done, animation.opts.complete )
		.fail( animation.opts.fail )
		.always( animation.opts.always );

	jQuery.fx.timer(
		jQuery.extend( tick, {
			elem: elem,
			anim: animation,
			queue: animation.opts.queue
		} )
	);

	return animation;
}

jQuery.Animation = jQuery.extend( Animation, {

	tweeners: {
		"*": [ function( prop, value ) {
			var tween = this.createTween( prop, value );
			adjustCSS( tween.elem, prop, rcssNum.exec( value ), tween );
			return tween;
		} ]
	},

	tweener: function( props, callback ) {
		if ( isFunction( props ) ) {
			callback = props;
			props = [ "*" ];
		} else {
			props = props.match( rnothtmlwhite );
		}

		var prop,
			index = 0,
			length = props.length;

		for ( ; index < length; index++ ) {
			prop = props[ index ];
			Animation.tweeners[ prop ] = Animation.tweeners[ prop ] || [];
			Animation.tweeners[ prop ].unshift( callback );
		}
	},

	prefilters: [ defaultPrefilter ],

	prefilter: function( callback, prepend ) {
		if ( prepend ) {
			Animation.prefilters.unshift( callback );
		} else {
			Animation.prefilters.push( callback );
		}
	}
} );

jQuery.speed = function( speed, easing, fn ) {
	var opt = speed && typeof speed === "object" ? jQuery.extend( {}, speed ) : {
		complete: fn || !fn && easing ||
			isFunction( speed ) && speed,
		duration: speed,
		easing: fn && easing || easing && !isFunction( easing ) && easing
	};

	if ( jQuery.fx.off ) {
		opt.duration = 0;

	} else {
		if ( typeof opt.duration !== "number" ) {
			if ( opt.duration in jQuery.fx.speeds ) {
				opt.duration = jQuery.fx.speeds[ opt.duration ];

			} else {
				opt.duration = jQuery.fx.speeds._default;
			}
		}
	}

	if ( opt.queue == null || opt.queue === true ) {
		opt.queue = "fx";
	}

	opt.old = opt.complete;

	opt.complete = function() {
		if ( isFunction( opt.old ) ) {
			opt.old.call( this );
		}

		if ( opt.queue ) {
			jQuery.dequeue( this, opt.queue );
		}
	};

	return opt;
};

jQuery.fn.extend( {
	animate: function( prop, speed, easing, callback ) {
		var empty = jQuery.isEmptyObject( prop ),
			optall = jQuery.speed( speed, easing, callback ),
			doAnimation = function() {

				var anim = Animation( this, jQuery.extend( {}, prop ), optall );

				if ( empty || dataPriv.get( this, "finish" ) ) {
					anim.stop( true );
				}
			};

		doAnimation.finish = doAnimation;

		return empty || optall.queue === false ?
			this.each( doAnimation ) :
			this.queue( optall.queue, doAnimation );
	},
	stop: function( type, clearQueue, gotoEnd ) {
		var stopQueue = function( hooks ) {
			var stop = hooks.stop;
			delete hooks.stop;
			stop( gotoEnd );
		};

		if ( typeof type !== "string" ) {
			gotoEnd = clearQueue;
			clearQueue = type;
			type = undefined;
		}
		if ( clearQueue ) {
			this.queue( type || "fx", [] );
		}

		return this.each( function() {
			var dequeue = true,
				index = type != null && type + "queueHooks",
				timers = jQuery.timers,
				data = dataPriv.get( this );

			if ( index ) {
				if ( data[ index ] && data[ index ].stop ) {
					stopQueue( data[ index ] );
				}
			} else {
				for ( index in data ) {
					if ( data[ index ] && data[ index ].stop && rrun.test( index ) ) {
						stopQueue( data[ index ] );
					}
				}
			}

			for ( index = timers.length; index--; ) {
				if ( timers[ index ].elem === this &&
					( type == null || timers[ index ].queue === type ) ) {

					timers[ index ].anim.stop( gotoEnd );
					dequeue = false;
					timers.splice( index, 1 );
				}
			}

			if ( dequeue || !gotoEnd ) {
				jQuery.dequeue( this, type );
			}
		} );
	},
	finish: function( type ) {
		if ( type !== false ) {
			type = type || "fx";
		}
		return this.each( function() {
			var index,
				data = dataPriv.get( this ),
				queue = data[ type + "queue" ],
				hooks = data[ type + "queueHooks" ],
				timers = jQuery.timers,
				length = queue ? queue.length : 0;

			data.finish = true;

			jQuery.queue( this, type, [] );

			if ( hooks && hooks.stop ) {
				hooks.stop.call( this, true );
			}

			for ( index = timers.length; index--; ) {
				if ( timers[ index ].elem === this && timers[ index ].queue === type ) {
					timers[ index ].anim.stop( true );
					timers.splice( index, 1 );
				}
			}

			for ( index = 0; index < length; index++ ) {
				if ( queue[ index ] && queue[ index ].finish ) {
					queue[ index ].finish.call( this );
				}
			}

			delete data.finish;
		} );
	}
} );

jQuery.each( [ "toggle", "show", "hide" ], function( _i, name ) {
	var cssFn = jQuery.fn[ name ];
	jQuery.fn[ name ] = function( speed, easing, callback ) {
		return speed == null || typeof speed === "boolean" ?
			cssFn.apply( this, arguments ) :
			this.animate( genFx( name, true ), speed, easing, callback );
	};
} );

jQuery.each( {
	slideDown: genFx( "show" ),
	slideUp: genFx( "hide" ),
	slideToggle: genFx( "toggle" ),
	fadeIn: { opacity: "show" },
	fadeOut: { opacity: "hide" },
	fadeToggle: { opacity: "toggle" }
}, function( name, props ) {
	jQuery.fn[ name ] = function( speed, easing, callback ) {
		return this.animate( props, speed, easing, callback );
	};
} );

jQuery.timers = [];
jQuery.fx.tick = function() {
	var timer,
		i = 0,
		timers = jQuery.timers;

	fxNow = Date.now();

	for ( ; i < timers.length; i++ ) {
		timer = timers[ i ];

		if ( !timer() && timers[ i ] === timer ) {
			timers.splice( i--, 1 );
		}
	}

	if ( !timers.length ) {
		jQuery.fx.stop();
	}
	fxNow = undefined;
};

jQuery.fx.timer = function( timer ) {
	jQuery.timers.push( timer );
	jQuery.fx.start();
};

jQuery.fx.interval = 13;
jQuery.fx.start = function() {
	if ( inProgress ) {
		return;
	}

	inProgress = true;
	schedule();
};

jQuery.fx.stop = function() {
	inProgress = null;
};

jQuery.fx.speeds = {
	slow: 600,
	fast: 200,

	_default: 400
};


jQuery.fn.delay = function( time, type ) {
	time = jQuery.fx ? jQuery.fx.speeds[ time ] || time : time;
	type = type || "fx";

	return this.queue( type, function( next, hooks ) {
		var timeout = window.setTimeout( next, time );
		hooks.stop = function() {
			window.clearTimeout( timeout );
		};
	} );
};


( function() {
	var input = document.createElement( "input" ),
		select = document.createElement( "select" ),
		opt = select.appendChild( document.createElement( "option" ) );

	input.type = "checkbox";
	support.checkOn = input.value !== "";
	support.optSelected = opt.selected;
	input = document.createElement( "input" );
	input.value = "t";
	input.type = "radio";
	support.radioValue = input.value === "t";
} )();


var boolHook,
	attrHandle = jQuery.expr.attrHandle;

jQuery.fn.extend( {
	attr: function( name, value ) {
		return access( this, jQuery.attr, name, value, arguments.length > 1 );
	},

	removeAttr: function( name ) {
		return this.each( function() {
			jQuery.removeAttr( this, name );
		} );
	}
} );

jQuery.extend( {
	attr: function( elem, name, value ) {
		var ret, hooks,
			nType = elem.nodeType;

		if ( nType === 3 || nType === 8 || nType === 2 ) {
			return;
		}

		if ( typeof elem.getAttribute === "undefined" ) {
			return jQuery.prop( elem, name, value );
		}

		if ( nType !== 1 || !jQuery.isXMLDoc( elem ) ) {
			hooks = jQuery.attrHooks[ name.toLowerCase() ] ||
				( jQuery.expr.match.bool.test( name ) ? boolHook : undefined );
		}

		if ( value !== undefined ) {
			if ( value === null ) {
				jQuery.removeAttr( elem, name );
				return;
			}

			if ( hooks && "set" in hooks &&
				( ret = hooks.set( elem, value, name ) ) !== undefined ) {
				return ret;
			}

			elem.setAttribute( name, value + "" );
			return value;
		}

		if ( hooks && "get" in hooks && ( ret = hooks.get( elem, name ) ) !== null ) {
			return ret;
		}

		ret = jQuery.find.attr( elem, name );

		return ret == null ? undefined : ret;
	},

	attrHooks: {
		type: {
			set: function( elem, value ) {
				if ( !support.radioValue && value === "radio" &&
					nodeName( elem, "input" ) ) {
					var val = elem.value;
					elem.setAttribute( "type", value );
					if ( val ) {
						elem.value = val;
					}
					return value;
				}
			}
		}
	},

	removeAttr: function( elem, value ) {
		var name,
			i = 0,

			attrNames = value && value.match( rnothtmlwhite );

		if ( attrNames && elem.nodeType === 1 ) {
			while ( ( name = attrNames[ i++ ] ) ) {
				elem.removeAttribute( name );
			}
		}
	}
} );

boolHook = {
	set: function( elem, value, name ) {
		if ( value === false ) {
			jQuery.removeAttr( elem, name );
		} else {
			elem.setAttribute( name, name );
		}
		return name;
	}
};

jQuery.each( jQuery.expr.match.bool.source.match( /\w+/g ), function( _i, name ) {
	var getter = attrHandle[ name ] || jQuery.find.attr;

	attrHandle[ name ] = function( elem, name, isXML ) {
		var ret, handle,
			lowercaseName = name.toLowerCase();

		if ( !isXML ) {

			handle = attrHandle[ lowercaseName ];
			attrHandle[ lowercaseName ] = ret;
			ret = getter( elem, name, isXML ) != null ?
				lowercaseName :
				null;
			attrHandle[ lowercaseName ] = handle;
		}
		return ret;
	};
} );




var rfocusable = /^(?:input|select|textarea|button)$/i,
	rclickable = /^(?:a|area)$/i;

jQuery.fn.extend( {
	prop: function( name, value ) {
		return access( this, jQuery.prop, name, value, arguments.length > 1 );
	},

	removeProp: function( name ) {
		return this.each( function() {
			delete this[ jQuery.propFix[ name ] || name ];
		} );
	}
} );

jQuery.extend( {
	prop: function( elem, name, value ) {
		var ret, hooks,
			nType = elem.nodeType;

		if ( nType === 3 || nType === 8 || nType === 2 ) {
			return;
		}

		if ( nType !== 1 || !jQuery.isXMLDoc( elem ) ) {

			name = jQuery.propFix[ name ] || name;
			hooks = jQuery.propHooks[ name ];
		}

		if ( value !== undefined ) {
			if ( hooks && "set" in hooks &&
				( ret = hooks.set( elem, value, name ) ) !== undefined ) {
				return ret;
			}

			return ( elem[ name ] = value );
		}

		if ( hooks && "get" in hooks && ( ret = hooks.get( elem, name ) ) !== null ) {
			return ret;
		}

		return elem[ name ];
	},

	propHooks: {
		tabIndex: {
			get: function( elem ) {
				var tabindex = jQuery.find.attr( elem, "tabindex" );

				if ( tabindex ) {
					return parseInt( tabindex, 10 );
				}

				if (
					rfocusable.test( elem.nodeName ) ||
					rclickable.test( elem.nodeName ) &&
					elem.href
				) {
					return 0;
				}

				return -1;
			}
		}
	},

	propFix: {
		"for": "htmlFor",
		"class": "className"
	}
} );

if ( !support.optSelected ) {
	jQuery.propHooks.selected = {
		get: function( elem ) {
			var parent = elem.parentNode;
			if ( parent && parent.parentNode ) {
				parent.parentNode.selectedIndex;
			}
			return null;
		},
		set: function( elem ) {

			var parent = elem.parentNode;
			if ( parent ) {
				parent.selectedIndex;

				if ( parent.parentNode ) {
					parent.parentNode.selectedIndex;
				}
			}
		}
	};
}

jQuery.each( [
	"tabIndex",
	"readOnly",
	"maxLength",
	"cellSpacing",
	"cellPadding",
	"rowSpan",
	"colSpan",
	"useMap",
	"frameBorder",
	"contentEditable"
], function() {
	jQuery.propFix[ this.toLowerCase() ] = this;
} );


	function stripAndCollapse( value ) {
		var tokens = value.match( rnothtmlwhite ) || [];
		return tokens.join( " " );
	}


function getClass( elem ) {
	return elem.getAttribute && elem.getAttribute( "class" ) || "";
}

function classesToArray( value ) {
	if ( Array.isArray( value ) ) {
		return value;
	}
	if ( typeof value === "string" ) {
		return value.match( rnothtmlwhite ) || [];
	}
	return [];
}

jQuery.fn.extend( {
	addClass: function( value ) {
		var classes, elem, cur, curValue, clazz, j, finalValue,
			i = 0;

		if ( isFunction( value ) ) {
			return this.each( function( j ) {
				jQuery( this ).addClass( value.call( this, j, getClass( this ) ) );
			} );
		}

		classes = classesToArray( value );

		if ( classes.length ) {
			while ( ( elem = this[ i++ ] ) ) {
				curValue = getClass( elem );
				cur = elem.nodeType === 1 && ( " " + stripAndCollapse( curValue ) + " " );

				if ( cur ) {
					j = 0;
					while ( ( clazz = classes[ j++ ] ) ) {
						if ( cur.indexOf( " " + clazz + " " ) < 0 ) {
							cur += clazz + " ";
						}
					}

					finalValue = stripAndCollapse( cur );
					if ( curValue !== finalValue ) {
						elem.setAttribute( "class", finalValue );
					}
				}
			}
		}

		return this;
	},

	removeClass: function( value ) {
		var classes, elem, cur, curValue, clazz, j, finalValue,
			i = 0;

		if ( isFunction( value ) ) {
			return this.each( function( j ) {
				jQuery( this ).removeClass( value.call( this, j, getClass( this ) ) );
			} );
		}

		if ( !arguments.length ) {
			return this.attr( "class", "" );
		}

		classes = classesToArray( value );

		if ( classes.length ) {
			while ( ( elem = this[ i++ ] ) ) {
				curValue = getClass( elem );

				cur = elem.nodeType === 1 && ( " " + stripAndCollapse( curValue ) + " " );

				if ( cur ) {
					j = 0;
					while ( ( clazz = classes[ j++ ] ) ) {

						while ( cur.indexOf( " " + clazz + " " ) > -1 ) {
							cur = cur.replace( " " + clazz + " ", " " );
						}
					}

					finalValue = stripAndCollapse( cur );
					if ( curValue !== finalValue ) {
						elem.setAttribute( "class", finalValue );
					}
				}
			}
		}

		return this;
	}
} );




var rreturn = /\r/g;

jQuery.fn.extend( {
	val: function( value ) {
		var hooks, ret, valueIsFunction,
			elem = this[ 0 ];

		if ( !arguments.length ) {
			if ( elem ) {
				hooks = jQuery.valHooks[ elem.type ] ||
					jQuery.valHooks[ elem.nodeName.toLowerCase() ];

				if ( hooks &&
					"get" in hooks &&
					( ret = hooks.get( elem, "value" ) ) !== undefined
				) {
					return ret;
				}

				ret = elem.value;

				if ( typeof ret === "string" ) {
					return ret.replace( rreturn, "" );
				}

				return ret == null ? "" : ret;
			}

			return;
		}

		valueIsFunction = isFunction( value );

		return this.each( function( i ) {
			var val;

			if ( this.nodeType !== 1 ) {
				return;
			}

			if ( valueIsFunction ) {
				val = value.call( this, i, jQuery( this ).val() );
			} else {
				val = value;
			}

			if ( val == null ) {
				val = "";

			} else if ( typeof val === "number" ) {
				val += "";

			} else if ( Array.isArray( val ) ) {
				val = jQuery.map( val, function( value ) {
					return value == null ? "" : value + "";
				} );
			}

			hooks = jQuery.valHooks[ this.type ] || jQuery.valHooks[ this.nodeName.toLowerCase() ];

			if ( !hooks || !( "set" in hooks ) || hooks.set( this, val, "value" ) === undefined ) {
				this.value = val;
			}
		} );
	}
} );

jQuery.extend( {
	valHooks: {
		option: {
			get: function( elem ) {

				var val = jQuery.find.attr( elem, "value" );
				return val != null ?
					val :

					stripAndCollapse( jQuery.text( elem ) );
			}
		},
		select: {
			get: function( elem ) {
				var value, option, i,
					options = elem.options,
					index = elem.selectedIndex,
					one = elem.type === "select-one",
					values = one ? null : [],
					max = one ? index + 1 : options.length;

				if ( index < 0 ) {
					i = max;

				} else {
					i = one ? index : 0;
				}

				for ( ; i < max; i++ ) {
					option = options[ i ];

					if ( ( option.selected || i === index ) &&

							!option.disabled &&
							( !option.parentNode.disabled ||
								!nodeName( option.parentNode, "optgroup" ) ) ) {

						value = jQuery( option ).val();

						if ( one ) {
							return value;
						}

						values.push( value );
					}
				}

				return values;
			},

			set: function( elem, value ) {
				var optionSet, option,
					options = elem.options,
					values = jQuery.makeArray( value ),
					i = options.length;

				while ( i-- ) {
					option = options[ i ];


					if ( option.selected =
						jQuery.inArray( jQuery.valHooks.option.get( option ), values ) > -1
					) {
						optionSet = true;
					}

				}

				if ( !optionSet ) {
					elem.selectedIndex = -1;
				}
				return values;
			}
		}
	}
} );

jQuery.each( [ "radio", "checkbox" ], function() {
	jQuery.valHooks[ this ] = {
		set: function( elem, value ) {
			if ( Array.isArray( value ) ) {
				return ( elem.checked = jQuery.inArray( jQuery( elem ).val(), value ) > -1 );
			}
		}
	};
	if ( !support.checkOn ) {
		jQuery.valHooks[ this ].get = function( elem ) {
			return elem.getAttribute( "value" ) === null ? "on" : elem.value;
		};
	}
} );


support.focusin = "onfocusin" in window;


var rfocusMorph = /^(?:focusinfocus|focusoutblur)$/,
	stopPropagationCallback = function( e ) {
		e.stopPropagation();
	};

jQuery.extend( jQuery.event, {

	trigger: function( event, data, elem, onlyHandlers ) {

		var i, cur, tmp, bubbleType, ontype, handle, special, lastElement,
			eventPath = [ elem || document ],
			type = hasOwn.call( event, "type" ) ? event.type : event,
			namespaces = hasOwn.call( event, "namespace" ) ? event.namespace.split( "." ) : [];

		cur = lastElement = tmp = elem = elem || document;

		if ( elem.nodeType === 3 || elem.nodeType === 8 ) {
			return;
		}

		if ( rfocusMorph.test( type + jQuery.event.triggered ) ) {
			return;
		}

		if ( type.indexOf( "." ) > -1 ) {

			namespaces = type.split( "." );
			type = namespaces.shift();
			namespaces.sort();
		}
		ontype = type.indexOf( ":" ) < 0 && "on" + type;

		event = event[ jQuery.expando ] ?
			event :
			new jQuery.Event( type, typeof event === "object" && event );

		event.isTrigger = onlyHandlers ? 2 : 3;
		event.namespace = namespaces.join( "." );
		event.rnamespace = event.namespace ?
			new RegExp( "(^|\\.)" + namespaces.join( "\\.(?:.*\\.|)" ) + "(\\.|$)" ) :
			null;

		event.result = undefined;
		if ( !event.target ) {
			event.target = elem;
		}

		data = data == null ?
			[ event ] :
			jQuery.makeArray( data, [ event ] );

		special = jQuery.event.special[ type ] || {};
		if ( !onlyHandlers && special.trigger && special.trigger.apply( elem, data ) === false ) {
			return;
		}

		if ( !onlyHandlers && !special.noBubble && !isWindow( elem ) ) {

			bubbleType = special.delegateType || type;
			if ( !rfocusMorph.test( bubbleType + type ) ) {
				cur = cur.parentNode;
			}
			for ( ; cur; cur = cur.parentNode ) {
				eventPath.push( cur );
				tmp = cur;
			}

			if ( tmp === ( elem.ownerDocument || document ) ) {
				eventPath.push( tmp.defaultView || tmp.parentWindow || window );
			}
		}

		i = 0;
		while ( ( cur = eventPath[ i++ ] ) && !event.isPropagationStopped() ) {
			lastElement = cur;
			event.type = i > 1 ?
				bubbleType :
				special.bindType || type;

			handle = ( dataPriv.get( cur, "events" ) || Object.create( null ) )[ event.type ] &&
				dataPriv.get( cur, "handle" );
			if ( handle ) {
				handle.apply( cur, data );
			}

			handle = ontype && cur[ ontype ];
			if ( handle && handle.apply && acceptData( cur ) ) {
				event.result = handle.apply( cur, data );
				if ( event.result === false ) {
					event.preventDefault();
				}
			}
		}
		event.type = type;

		if ( !onlyHandlers && !event.isDefaultPrevented() ) {

			if ( ( !special._default ||
				special._default.apply( eventPath.pop(), data ) === false ) &&
				acceptData( elem ) ) {

				if ( ontype && isFunction( elem[ type ] ) && !isWindow( elem ) ) {

					tmp = elem[ ontype ];

					if ( tmp ) {
						elem[ ontype ] = null;
					}

					jQuery.event.triggered = type;

					if ( event.isPropagationStopped() ) {
						lastElement.addEventListener( type, stopPropagationCallback );
					}

					elem[ type ]();

					if ( event.isPropagationStopped() ) {
						lastElement.removeEventListener( type, stopPropagationCallback );
					}

					jQuery.event.triggered = undefined;

					if ( tmp ) {
						elem[ ontype ] = tmp;
					}
				}
			}
		}

		return event.result;
	},
	simulate: function( type, elem, event ) {
		var e = jQuery.extend(
			new jQuery.Event(),
			event,
			{
				type: type,
				isSimulated: true
			}
		);

		jQuery.event.trigger( e, null, elem );
	}

} );

jQuery.fn.extend( {

	trigger: function( type, data ) {
		return this.each( function() {
			jQuery.event.trigger( type, data, this );
		} );
	}
} );

if ( !support.focusin ) {
	jQuery.each( { focus: "focusin", blur: "focusout" }, function( orig, fix ) {

		var handler = function( event ) {
			jQuery.event.simulate( fix, event.target, jQuery.event.fix( event ) );
		};

		jQuery.event.special[ fix ] = {
			setup: function() {
				var doc = this.ownerDocument || this.document || this,
					attaches = dataPriv.access( doc, fix );

				if ( !attaches ) {
					doc.addEventListener( orig, handler, true );
				}
				dataPriv.access( doc, fix, ( attaches || 0 ) + 1 );
			},
			teardown: function() {
				var doc = this.ownerDocument || this.document || this,
					attaches = dataPriv.access( doc, fix ) - 1;

				if ( !attaches ) {
					doc.removeEventListener( orig, handler, true );
					dataPriv.remove( doc, fix );

				} else {
					dataPriv.access( doc, fix, attaches );
				}
			}
		};
	} );
}
var location = window.location;

var nonce = { guid: Date.now() };

var rquery = ( /\?/ );


var
	rbracket = /\[\]$/,
	rCRLF = /\r?\n/g,
	rsubmitterTypes = /^(?:submit|button|image|reset|file)$/i,
	rsubmittable = /^(?:input|select|textarea|keygen)/i;

function buildParams( prefix, obj, traditional, add ) {
	var name;

	if ( Array.isArray( obj ) ) {

		jQuery.each( obj, function( i, v ) {
			if ( traditional || rbracket.test( prefix ) ) {

				add( prefix, v );

			} else {

				buildParams(
					prefix + "[" + ( typeof v === "object" && v != null ? i : "" ) + "]",
					v,
					traditional,
					add
				);
			}
		} );

	} else if ( !traditional && toType( obj ) === "object" ) {

		for ( name in obj ) {
			buildParams( prefix + "[" + name + "]", obj[ name ], traditional, add );
		}

	} else {

		add( prefix, obj );
	}
}

jQuery.param = function( a, traditional ) {
	var prefix,
		s = [],
		add = function( key, valueOrFunction ) {

			var value = isFunction( valueOrFunction ) ?
				valueOrFunction() :
				valueOrFunction;

			s[ s.length ] = encodeURIComponent( key ) + "=" +
				encodeURIComponent( value == null ? "" : value );
		};

	if ( a == null ) {
		return "";
	}

	if ( Array.isArray( a ) || ( a.jquery && !jQuery.isPlainObject( a ) ) ) {

		jQuery.each( a, function() {
			add( this.name, this.value );
		} );

	} else {
		for ( prefix in a ) {
			buildParams( prefix, a[ prefix ], traditional, add );
		}
	}

	return s.join( "&" );
};

jQuery.fn.extend( {
	serialize: function() {
		return jQuery.param( this.serializeArray() );
	},
	serializeArray: function() {
		return this.map( function() {

			var elements = jQuery.prop( this, "elements" );
			return elements ? jQuery.makeArray( elements ) : this;
		} ).filter( function() {
			var type = this.type;

			return this.name && !jQuery( this ).is( ":disabled" ) &&
				rsubmittable.test( this.nodeName ) && !rsubmitterTypes.test( type ) &&
				( this.checked || !rcheckableType.test( type ) );
		} ).map( function( _i, elem ) {
			var val = jQuery( this ).val();

			if ( val == null ) {
				return null;
			}

			if ( Array.isArray( val ) ) {
				return jQuery.map( val, function( val ) {
					return { name: elem.name, value: val.replace( rCRLF, "\r\n" ) };
				} );
			}

			return { name: elem.name, value: val.replace( rCRLF, "\r\n" ) };
		} ).get();
	}
} );


var
	r20 = /%20/g,
	rhash = /#.*$/,
	rantiCache = /([?&])_=[^&]*/,
	rheaders = /^(.*?):[ \t]*([^\r\n]*)$/mg,
	rlocalProtocol = /^(?:about|app|app-storage|.+-extension|file|res|widget):$/,
	rnoContent = /^(?:GET|HEAD)$/,
	rprotocol = /^\/\//,
	prefilters = {},
	transports = {},
	allTypes = "*/".concat( "*" ),
	originAnchor = document.createElement( "a" );

originAnchor.href = location.href;

jQuery.fn.extend( {
	wrapAll: function( html ) {
		var wrap;

		if ( this[ 0 ] ) {
			if ( isFunction( html ) ) {
				html = html.call( this[ 0 ] );
			}

			wrap = jQuery( html, this[ 0 ].ownerDocument ).eq( 0 ).clone( true );

			if ( this[ 0 ].parentNode ) {
				wrap.insertBefore( this[ 0 ] );
			}

			wrap.map( function() {
				var elem = this;

				while ( elem.firstElementChild ) {
					elem = elem.firstElementChild;
				}

				return elem;
			} ).append( this );
		}

		return this;
	},

	wrapInner: function( html ) {
		if ( isFunction( html ) ) {
			return this.each( function( i ) {
				jQuery( this ).wrapInner( html.call( this, i ) );
			} );
		}

		return this.each( function() {
			var self = jQuery( this ),
				contents = self.contents();

			if ( contents.length ) {
				contents.wrapAll( html );

			} else {
				self.append( html );
			}
		} );
	},

	wrap: function( html ) {
		var htmlIsFunction = isFunction( html );

		return this.each( function( i ) {
			jQuery( this ).wrapAll( htmlIsFunction ? html.call( this, i ) : html );
		} );
	},

	unwrap: function( selector ) {
		this.parent( selector ).not( "body" ).each( function() {
			jQuery( this ).replaceWith( this.childNodes );
		} );
		return this;
	}
} );


jQuery.expr.pseudos.hidden = function( elem ) {
	return !jQuery.expr.pseudos.visible( elem );
};
jQuery.expr.pseudos.visible = function( elem ) {
	return !!( elem.offsetWidth || elem.offsetHeight || elem.getClientRects().length );
};




var oldCallbacks = [],
	rjsonp = /(=)\?(?=&|$)|\?\?/;


support.createHTMLDocument = ( function() {
	var body = document.implementation.createHTMLDocument( "" ).body;
	body.innerHTML = "<form></form><form></form>";
	return body.childNodes.length === 2;
} )();


jQuery.parseHTML = function( data, context, keepScripts ) {
	if ( typeof data !== "string" ) {
		return [];
	}
	if ( typeof context === "boolean" ) {
		keepScripts = context;
		context = false;
	}

	var base, parsed, scripts;

	if ( !context ) {

		if ( support.createHTMLDocument ) {
			context = document.implementation.createHTMLDocument( "" );

			base = context.createElement( "base" );
			base.href = document.location.href;
			context.head.appendChild( base );
		} else {
			context = document;
		}
	}

	parsed = rsingleTag.exec( data );
	scripts = !keepScripts && [];

	// Single tag
	if ( parsed ) {
		return [ context.createElement( parsed[ 1 ] ) ];
	}

	parsed = buildFragment( [ data ], context, scripts );

	if ( scripts && scripts.length ) {
		jQuery( scripts ).remove();
	}

	return jQuery.merge( [], parsed.childNodes );
};



jQuery.expr.pseudos.animated = function( elem ) {
	return jQuery.grep( jQuery.timers, function( fn ) {
		return elem === fn.elem;
	} ).length;
};




jQuery.offset = {
	setOffset: function( elem, options, i ) {
		var curPosition, curLeft, curCSSTop, curTop, curOffset, curCSSLeft, calculatePosition,
			position = jQuery.css( elem, "position" ),
			curElem = jQuery( elem ),
			props = {};

		if ( position === "static" ) {
			elem.style.position = "relative";
		}

		curOffset = curElem.offset();
		curCSSTop = jQuery.css( elem, "top" );
		curCSSLeft = jQuery.css( elem, "left" );
		calculatePosition = ( position === "absolute" || position === "fixed" ) &&
			( curCSSTop + curCSSLeft ).indexOf( "auto" ) > -1;

		if ( calculatePosition ) {
			curPosition = curElem.position();
			curTop = curPosition.top;
			curLeft = curPosition.left;

		} else {
			curTop = parseFloat( curCSSTop ) || 0;
			curLeft = parseFloat( curCSSLeft ) || 0;
		}

		if ( isFunction( options ) ) {

			options = options.call( elem, i, jQuery.extend( {}, curOffset ) );
		}

		if ( options.top != null ) {
			props.top = ( options.top - curOffset.top ) + curTop;
		}
		if ( options.left != null ) {
			props.left = ( options.left - curOffset.left ) + curLeft;
		}

		if ( "using" in options ) {
			options.using.call( elem, props );

		} else {
			curElem.css( props );
		}
	}
};

jQuery.fn.extend( {

	offset: function( options ) {

		if ( arguments.length ) {
			return options === undefined ?
				this :
				this.each( function( i ) {
					jQuery.offset.setOffset( this, options, i );
				} );
		}

		var rect, win,
			elem = this[ 0 ];

		if ( !elem ) {
			return;
		}

		if ( !elem.getClientRects().length ) {
			return { top: 0, left: 0 };
		}

		rect = elem.getBoundingClientRect();
		win = elem.ownerDocument.defaultView;
		return {
			top: rect.top + win.pageYOffset,
			left: rect.left + win.pageXOffset
		};
	},

	position: function() {
		if ( !this[ 0 ] ) {
			return;
		}

		var offsetParent, offset, doc,
			elem = this[ 0 ],
			parentOffset = { top: 0, left: 0 };

		if ( jQuery.css( elem, "position" ) === "fixed" ) {

			offset = elem.getBoundingClientRect();

		} else {
			offset = this.offset();
			doc = elem.ownerDocument;
			offsetParent = elem.offsetParent || doc.documentElement;
			while ( offsetParent &&
				( offsetParent === doc.body || offsetParent === doc.documentElement ) &&
				jQuery.css( offsetParent, "position" ) === "static" ) {

				offsetParent = offsetParent.parentNode;
			}
			if ( offsetParent && offsetParent !== elem && offsetParent.nodeType === 1 ) {

				parentOffset = jQuery( offsetParent ).offset();
				parentOffset.top += jQuery.css( offsetParent, "borderTopWidth", true );
				parentOffset.left += jQuery.css( offsetParent, "borderLeftWidth", true );
			}
		}

		return {
			top: offset.top - parentOffset.top - jQuery.css( elem, "marginTop", true ),
			left: offset.left - parentOffset.left - jQuery.css( elem, "marginLeft", true )
		};
	},
	offsetParent: function() {
		return this.map( function() {
			var offsetParent = this.offsetParent;

			while ( offsetParent && jQuery.css( offsetParent, "position" ) === "static" ) {
				offsetParent = offsetParent.offsetParent;
			}

			return offsetParent || documentElement;
		} );
	}
} );

jQuery.each( { scrollLeft: "pageXOffset", scrollTop: "pageYOffset" }, function( method, prop ) {
	var top = "pageYOffset" === prop;

	jQuery.fn[ method ] = function( val ) {
		return access( this, function( elem, method, val ) {

			var win;
			if ( isWindow( elem ) ) {
				win = elem;
			} else if ( elem.nodeType === 9 ) {
				win = elem.defaultView;
			}

			if ( val === undefined ) {
				return win ? win[ prop ] : elem[ method ];
			}

			if ( win ) {
				win.scrollTo(
					!top ? val : win.pageXOffset,
					top ? val : win.pageYOffset
				);

			} else {
				elem[ method ] = val;
			}
		}, method, val, arguments.length );
	};
} );

jQuery.each( [ "top", "left" ], function( _i, prop ) {
	jQuery.cssHooks[ prop ] = addGetHookIf( support.pixelPosition,
		function( elem, computed ) {
			if ( computed ) {
				computed = curCSS( elem, prop );

				return rnumnonpx.test( computed ) ?
					jQuery( elem ).position()[ prop ] + "px" :
					computed;
			}
		}
	);
} );

jQuery.each( { Height: "height", Width: "width" }, function( name, type ) {
	jQuery.each( {
		padding: "inner" + name,
		content: type,
		"": "outer" + name
	}, function( defaultExtra, funcName ) {

		jQuery.fn[ funcName ] = function( margin, value ) {
			var chainable = arguments.length && ( defaultExtra || typeof margin !== "boolean" ),
				extra = defaultExtra || ( margin === true || value === true ? "margin" : "border" );

			return access( this, function( elem, type, value ) {
				var doc;

				if ( isWindow( elem ) ) {

					return funcName.indexOf( "outer" ) === 0 ?
						elem[ "inner" + name ] :
						elem.document.documentElement[ "client" + name ];
				}

				if ( elem.nodeType === 9 ) {
					doc = elem.documentElement;
					return Math.max(
						elem.body[ "scroll" + name ], doc[ "scroll" + name ],
						elem.body[ "offset" + name ], doc[ "offset" + name ],
						doc[ "client" + name ]
					);
				}

				return value === undefined ?

					jQuery.css( elem, type, extra ) :

					jQuery.style( elem, type, value, extra );
			}, type, chainable ? margin : undefined, chainable );
		};
	} );
} );


jQuery.fn.extend( {

	bind: function( types, data, fn ) {
		return this.on( types, null, data, fn );
	},
	unbind: function( types, fn ) {
		return this.off( types, null, fn );
	},

	delegate: function( selector, types, data, fn ) {
		return this.on( types, selector, data, fn );
	},
	undelegate: function( selector, types, fn ) {

		// ( namespace ) or ( selector, types [, fn] )
		return arguments.length === 1 ?
			this.off( selector, "**" ) :
			this.off( types, selector || "**", fn );
	},

	hover: function( fnOver, fnOut ) {
		return this.mouseenter( fnOver ).mouseleave( fnOut || fnOver );
	}
} );

jQuery.each(
	( "blur focus focusin focusout resize scroll click dblclick " +
	"mousedown mouseup mousemove mouseover mouseout mouseenter mouseleave " +
	"change select submit keydown keypress keyup contextmenu" ).split( " " ),
	function( _i, name ) {

		jQuery.fn[ name ] = function( data, fn ) {
			return arguments.length > 0 ?
				this.on( name, null, data, fn ) :
				this.trigger( name );
		};
	}
);

var rtrim = /^[\s\uFEFF\xA0]+|[\s\uFEFF\xA0]+$/g;


jQuery.isArray = Array.isArray;
jQuery.parseJSON = JSON.parse;
jQuery.nodeName = nodeName;
jQuery.isFunction = isFunction;
jQuery.isWindow = isWindow;
jQuery.camelCase = camelCase;
jQuery.type = toType;

jQuery.now = Date.now;

jQuery.isNumeric = function( obj ) {

	var type = jQuery.type( obj );
	return ( type === "number" || type === "string" ) &&
		!isNaN( obj - parseFloat( obj ) );
};

jQuery.trim = function( text ) {
	return text == null ?
		"" :
		( text + "" ).replace( rtrim, "" );
};


if ( typeof define === "function" && define.amd ) {
	define( "jquery", [], function() {
		return jQuery;
	} );
}


var

	_jQuery = window.jQuery,

	_$ = window.$;

if ( typeof noGlobal === "undefined" ) {
	window.jQuery = window.$ = jQuery;
}




return jQuery;
} );

(function (factory) { //'use strict';
	if (typeof define === "function" && define.amd) {
		define(["jquery"], factory)
	} else if (typeof exports !== "undefined") {
		module.exports = factory(require("jquery"))
	} else {
		factory(jQuery)
	}
})

(function ($) { //'use strict';
	var EasyWheel = window.EasyWheel || {};
	EasyWheel = function () {
		var instanceUid = 0;

		function EasyWheel(element, settings) {
			var self = this,
				dataSettings;
			self.defaults = {
				items: [],
				width: 400,
				fontSize: 14,
				textOffset: 8,
				textLine: "h",
				textArc: false,
				letterSpacing: 0,
				textColor: "#fff",
				centerWidth: 45,
				shadow: "", // '#fff0', // egemen
				shadowOpacity: 0,
				centerLineWidth: 5,
				centerLineColor: "#424242",
				centerBackground: "#8e44ad",
				sliceLineWidth: 0,
				sliceLineColor: "#424242",
				selectedSliceColor: "#333",
				outerLineColor: "#424242",
				outerLineWidth: 5,
				centerImage: "",
				centerHtml: "",
				centerHtmlWidth: 45,
				centerImageWidth: 45,
				rotateCenter: false,
				easing: "easyWheel",
				markerAnimation: true,
				markerColor: "#CC3333",
				selector: "win",
				selected: [true],
				random: false,
				type: "spin",
				duration: 8000,
				rotates: 8,
				max: 0,
				frame: 1,
				onStart: function (results, spinCount, now) { },
				onStep: function (results, slicePercent, circlePercent) { },
				onProgress: function (results, spinCount, now) { },
				onComplete: function (results, spinCount, now) { },
				onFail: function (results, spinCount, now) { }
			};
			dataSettings = $(element).data("easyWheel") || {};
			self.o = $.extend({}, self.defaults, settings, dataSettings);
			self.initials = {
				slice: {
					id: null,
					results: null
				},
				currentSliceData: {
					id: null,
					results: null
				},
				winner: 0,
				rotates: parseInt(self.o.rotates),
				spinCount: 0,
				counter: 0,
				now: 0,
				currentSlice: 0,
				currentStep: 0,
				lastStep: 0,
				slicePercent: 0,
				circlePercent: 0,
				items: self.o.items,
				spinning: false,
				inProgress: false,
				nonce: null,
				$wheel: $(element)
			};
			$.extend(self, self.initials);
			$.extend($.easing, {
				easyWheel: function (x, t, b, c, d) {
					return -c * ((t = t / d - 1) * t * t * t - 1) + b
				}
			});
			$.extend($.easing, {
				easeOutQuad: function (x, t, b, c, d) {
					return -c * (t /= d) * (t - 2) + b
				}
			});
			$.extend($.easing, {
				MarkerEasing: function (x) {
					var n = -Math.pow(1 - x * 6, 2) + 1;
					if (n < 0) n = 0;
					return n
				}
			});
			self.instanceUid = "ew" + self.guid();
			self.validate();
			self.init();
			window.easyWheel = self; // egemen
		}
		return EasyWheel
	}();
	EasyWheel.prototype.validate = function (args) {
		var self = this;
		if (self.rotates < 1) {
			self.rotates = 1
		}
		if (parseInt(self.o.sliceLineWidth) > 10) {
			self.o.sliceLineWidth = 10
		}
		if (parseInt(self.o.centerLineWidth) > 10) {
			self.o.centerLineWidth = 10
		}
		if (parseInt(self.o.outerLineWidth) > 10) {
			self.o.outerLineWidth = 10
		}
		if (typeof $.easing[$.trim(self.o.easing)] == "undefined") {
			self.o.easing = "easyWheel"
		}
	};
	EasyWheel.prototype.destroy = function (args) {
		var self = this;
		if (self.spinning) {
			self.spinning.finish()
		}
		if (typeof args === "boolean" && args === true) self.$wheel.html("").removeClass(self.instanceUid);
		$.extend(self.o, self.defaults);
		$.extend(self, self.initials);
		$(document).off("click." + self.instanceUid);
		$(document).off("resize." + self.instanceUid)
	};
	EasyWheel.prototype.option = function (option, newValue) {
		var self = this;
		if ($.inArray(typeof newValue, ["undefined", "function"]) !== -1 || $.inArray(typeof self.o[option], ["undefined", "function"]) !== -1) return;
		var allowed = ["easing", "type", "duration", "rotates", "max"];
		if ($.inArray(option, allowed) == -1) return;
		self.o[option] = newValue
	};
	EasyWheel.prototype.finish = function () {
		var self = this;
		if (self.spinning) {
			self.spinning.finish()
		}
	};
	EasyWheel.prototype.init = function () {
		var self = this;
		self.initialize();
		self.execute()
	};
	EasyWheel.prototype.initialize = function () {
		var self = this;
		self.$wheel.addClass("easyWheel " + self.instanceUid);
		var color = "#ccc";
		var arcSize = 360 / self.totalSlices();
		var pStart = 0;
		var pEnd = 0;
		var colorIndex = 0;
		self.$wheel.html("");
		var wrapper = $("<div/>").addClass("eWheel-wrapper").appendTo(self.$wheel);
		var inner = $("<div/>").addClass("eWheel-inner").appendTo(wrapper);
		var spinner = $("<div/>").addClass("eWheel").prependTo(inner);
		var Layerbg = $("<div/>").addClass("eWheel-bg-layer").appendTo(spinner);
		var Layersvg = $(self.SVG("svg", {
			"version": "1.1",
			"xmlns": "http://www.w3.org/2000/svg",
			"xmlns:xlink": "http://www.w3.org/1999/xlink",
			"x": "0px",
			"y": "0px",
			"viewBox": "0 0 200 200",
			"xml:space": "preserve",
			"style": "enable-background:new 0 0 200 200;"
		}));
		Layersvg.appendTo(Layerbg);
		var slicesGroup = $("<g/>");
		var smallCirclesGroup = $("<g/>");
		slicesGroup.addClass("ew-slicesGroup").appendTo(Layersvg);
		if (self.o.textLine === "v" || self.o.textLine === "vertical") {
			var Layertext = $("<div/>");
			Layertext.addClass("eWheel-txt-wrap");
			Layertext.appendTo(spinner);
			var textHtml = $("<div/>");
			textHtml.addClass("eWheel-txt");
			textHtml.css({
				"-webkit-transform": "rotate(" + (-(360 / self.totalSlices()) / 2 + self.getDegree()) + "deg)",
				"-moz-transform": "rotate(" + (-(360 / self.totalSlices()) / 2 + self.getDegree()) + "deg)",
				"-ms-transform": "rotate(" + (-(360 / self.totalSlices()) / 2 + self.getDegree()) + "deg)",
				"-o-transform": "rotate(" + (-(360 / self.totalSlices()) / 2 + self.getDegree()) + "deg)",
				"transform": "rotate(" + (-(360 / self.totalSlices()) / 2 + self.getDegree()) + "deg)"
			});
			textHtml.appendTo(Layertext)
		} else {
			var textsGroup = $("<g/>");
			var LayerDefs = $("<defs/>");
			LayerDefs.appendTo(Layersvg);
			textsGroup.appendTo(Layersvg)
		}
		var Layercenter = $("<div/>");
		Layercenter.addClass("eWheel-center");
		Layercenter.appendTo(self.o.rotateCenter === true || self.o.rotateCenter === "true" ? spinner : inner);
		if (typeof self.o.centerHtml === "string" && $.trim(self.o.centerHtml) === "" && typeof self.o.centerImage === "string" && $.trim(self.o.centerImage) !== "") {
			var centerImage = $("<img />");
			if (!parseInt(self.o.centerImageWidth)) self.o.centerImageWidth = parseInt(self.o.centerWidth);
			centerImage.css("width", parseInt(self.o.centerImageWidth - 3) + "%");
			centerImage.attr("src", self.o.centerImage);
			centerImage.appendTo(Layercenter);
			Layercenter.append("<div class=\"ew-center-empty\" style=\"width:" + parseInt(self.o.centerImageWidth) + "%; height:" + parseInt(self.o.centerImageWidth) + "%\" />")
		}
		if (typeof self.o.centerHtml === "string" && $.trim(self.o.centerHtml) !== "") {
			var centerHtml = $("<div class=\"ew-center-html\">" + self.o.centerHtml + "</div>");
			if (!parseInt(self.o.centerHtmlWidth)) self.o.centerHtmlWidth = parseInt(self.o.centerWidth);
			centerHtml.css({
				"width": parseInt(self.o.centerHtmlWidth) + "%",
				"height": parseInt(self.o.centerHtmlWidth) + "%"
			});
			centerHtml.appendTo(Layercenter)
		}
		var Layermarker = false;
		if ($.trim(self.o.type) !== "color") {
			Layermarker = $("<div/>").addClass("eWheel-marker").appendTo(wrapper);
			Layermarker.append("<svg version=\"1.1\" id=\"Layer_1\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" x=\"0px\" y=\"0px\" viewBox=\"0 0 80 115\" style=\"enable-background:new 0 0 80 115;\" xml:space=\"preserve\">" + "<g>" + "<circle cx=\"40\" cy=\"25\" r=\"25\" fill=\"" + self.o.markerColor + "\" />" + "<path d=\"M41.5,103.1L63,34.5c0.3-1-0.4-2-1.5-2h-43c-1,0-1.8,1-1.5,2l21.5,68.6C39,104.5,41,104.5,41.5,103.1z\" fill=\"" + self.o.markerColor + "\" />" + "<circle cx=\"40\" cy=\"25\" r=\"10\" fill=\"#ffffff\" />" + "</g>" + "</svg>")
		}
		$.each(self.items, function (i, item) {
			var rotate = 360 / self.totalSlices() * i;
			pEnd += arcSize;
			var arcD = self.annularSector({
				centerX: 100,
				centerY: 100,
				startDegrees: pStart,
				endDegrees: pEnd,
				innerRadius: parseInt(self.o.centerWidth) + 0.5,
				outerRadius: 100.5 - parseInt(self.o.outerLineWidth)
			});
			slicesGroup.append(self.SVG("path", {
				"stroke-width": 0,
				"fill": item.color,
				"data-fill": item.color,
				"d": arcD
			}));
			var smallCirclePosition = self.getSmallCirclePosition({
				centerX: 100,
				centerY: 100,
				startDegrees: pEnd - 0.5,
				endDegrees: pEnd + 0.5,
				innerRadius: parseInt(self.o.centerWidth),
				outerRadius: 100.5 - parseInt(self.o.outerLineWidth) / 1.5
			});
			var rectWidth = 10;
			var rectHeight = 3;
			var rectRotate = rotate + 360 / self.items.length;
			smallCirclesGroup.append(self.SVG("rect", {
				"x": smallCirclePosition[0] - 1.5,
				"y": smallCirclePosition[1] - 1.5,
				"rx": 5,
				"ry": 5,
				"width": rectWidth,
				"height": rectHeight,
				"style": "fill:rgb(255,255,255);fill-opacity:1;",
				"transform": "rotate(" + rectRotate + " " + smallCirclePosition[0] + " " + smallCirclePosition[1] + ")"
			}));
			smallCirclesGroup.append(self.SVG("circle", {
				"cx": smallCirclePosition[0],
				"cy": smallCirclePosition[1],
				"r": 1.5,
				"fill": "black",
				"fill-opacity": 1
			}));
			var textColor = $.trim(self.o.textColor) !== "auto" ? $.trim(self.o.textColor) : self.brightness(item.color);
			if (self.o.textLine === "v" || self.o.textLine === "vertical") {
				var LayerTitle = $("<div/>");
				LayerTitle.addClass("eWheel-title");
				LayerTitle.html(item.name);
				LayerTitle.css({
					paddingRight: parseInt(self.o.textOffset) + "%",
					"-webkit-transform": "rotate(" + rotate + "deg) translate(0px, -50%)",
					"-moz-transform": "rotate(" + rotate + "deg) translate(0px, -50%)",
					"-ms-transform": "rotate(" + rotate + "deg) translate(0px, -50%)",
					"-o-transform": "rotate(" + rotate + "deg) translate(0px, -50%)",
					"transform": "rotate(" + rotate + "deg) translate(0px, -50%)",
					"color": textColor
				});
				LayerTitle.appendTo(textHtml);
				if (self.toNumber(self.o.letterSpacing) > 0) textHtml.css("letter-spacing", self.toNumber(self.o.letterSpacing))
			} else {
				var LayerText = "<text stroke-width=\"0\" fill=\"" + textColor + "\" dy=\"" + self.toNumber(self.o.textOffset) + "%\">" + "<textPath xlink:href=\"#ew-text-" + i + "\" startOffset=\"50%\" style=\"text-anchor: middle;\">" + item.name + "</textPath>" + "</text>";
				textsGroup.css("font-size", parseInt(self.o.fontSize) / 2);
				if (parseInt(self.o.letterSpacing) > 0) textsGroup.css("letter-spacing", parseInt(self.o.letterSpacing));
				textsGroup.append(LayerText);
				var firstArcSection = /(^.+?)L/;
				var newD = firstArcSection.exec(arcD)[1];
				if (self.o.textArc !== true) {
					var secArcSection = /(^.+?)A/;
					var Commas = /(^.+?),/;
					var newc = secArcSection.exec(newD);
					var replaceVal = newD.replace(newc[0], "");
					var getFirstANumber = Commas.exec(replaceVal);
					var nval = replaceVal.replace(getFirstANumber[1], 0);
					newD = newD.replace(replaceVal, nval)
				}
				LayerDefs.append(self.SVG("path", {
					"stroke-width": 0,
					"fill": "none",
					"id": "ew-text-" + i,
					"d": newD
				}))
			}
			var LayerTitleInner = $("<div/>");
			LayerTitleInner.html(item);
			LayerTitleInner.appendTo(LayerTitle);
			pStart += arcSize
		});
		var sliceLineWidth = parseInt(self.o.sliceLineWidth);
		if (self.o.textLine !== "v" || self.o.textLine !== "vertical") { }
		if (parseInt(self.o.centerWidth) > sliceLineWidth) {
			var centerCircle = self.SVG("circle", {
				"class": "centerCircle",
				"cx": "100",
				"cy": "100",
				"r": parseInt(self.o.centerWidth) + 1,
				"stroke": self.o.centerLineColor,
				"stroke-width": parseInt(self.o.centerLineWidth),
				"fill": self.o.centerBackground
			});
			$(centerCircle).appendTo(Layersvg)
		}
		var outerLine = self.SVG("circle", {
			"cx": "100",
			"cy": "100",
			"r": 100 - parseInt(self.o.outerLineWidth) / 2,
			"stroke": self.o.outerLineColor,
			"stroke-width": parseInt(self.o.outerLineWidth),
			"fill-opacity": 0,
			"fill": "#fff0"
		});
		$(outerLine).appendTo(Layersvg);
		smallCirclesGroup.addClass("ew-smallCirclesGroup").appendTo(Layersvg);
		Layerbg.html(Layerbg.html())
	};
	EasyWheel.prototype.toNumber = function (e) {
		return NaN === Number(e) ? 0 : Number(e)
	};
	EasyWheel.prototype.SVG = function (e, t) {
		var r = document.createElementNS("http://www.w3.org/2000/svg", e);
		for (var n in t) r.setAttribute(n, t[n]);
		return r
	};
	EasyWheel.prototype.getSmallCirclePosition = function (options) {
		var self = this;
		var lineSpace = parseInt(self.o.sliceLineWidth);
		var opts = self.oWithDefaults(options);
		return [opts.cx + opts.r2 * Math.cos((options.startDegrees + lineSpace / 4) * Math.PI / 180), opts.cy + opts.r2 * Math.sin((options.startDegrees + lineSpace / 4) * Math.PI / 180)]
	};
	EasyWheel.prototype.annularSector = function (options, line) {
		var self = this;
		var lineSpace = parseInt(self.o.sliceLineWidth);
		var opts = self.oWithDefaults(options);
		var p = [
			[opts.cx + opts.r2 * Math.cos((options.startDegrees + lineSpace / 4) * Math.PI / 180), opts.cy + opts.r2 * Math.sin((options.startDegrees + lineSpace / 4) * Math.PI / 180)],
			[opts.cx + opts.r2 * Math.cos((options.endDegrees - lineSpace / 4) * Math.PI / 180), opts.cy + opts.r2 * Math.sin((options.endDegrees - lineSpace / 4) * Math.PI / 180)],
			[opts.cx + opts.r1 * Math.cos((options.endDegrees - lineSpace) * Math.PI / 180), opts.cy + opts.r1 * Math.sin((options.endDegrees - lineSpace) * Math.PI / 180)],
			[opts.cx + opts.r1 * Math.cos((options.startDegrees + lineSpace) * Math.PI / 180), opts.cy + opts.r1 * Math.sin((options.startDegrees + lineSpace) * Math.PI / 180)]
		];
		var angleDiff = opts.closeRadians - opts.startRadians;
		var largeArc = angleDiff % (Math.PI * 2) > Math.PI ? 1 : 0;
		var N1 = 1;
		var N2 = 0;
		if (line === true && lineSpace >= parseInt(self.o.centerWidth)) {
			N1 = 0;
			N2 = 1
		} else if (line !== true && lineSpace >= parseInt(self.o.centerWidth)) {
			N1 = 1;
			N2 = 1
		}
		var cmds = [];
		cmds.push("M" + p[0].join());
		cmds.push("A" + [opts.r2, opts.r2, 0, largeArc, N1, p[1]].join());
		cmds.push("L" + p[2].join());
		cmds.push("A" + [opts.r1, opts.r1, 0, largeArc, N2, p[3]].join());
		cmds.push("z");
		return cmds.join(" ")
	};
	EasyWheel.prototype.oWithDefaults = function (o) {
		var o2 = {
			cx: o.centerX || 0,
			cy: o.centerY || 0,
			startRadians: (o.startDegrees || 0) * Math.PI / 180,
			closeRadians: (o.endDegrees || 0) * Math.PI / 180
		};
		var t = o.thickness !== undefined ? o.thickness : 100;
		if (o.innerRadius !== undefined) o2.r1 = o.innerRadius;
		else if (o.outerRadius !== undefined) o2.r1 = o.outerRadius - t;
		else o2.r1 = 200 - t;
		if (o.outerRadius !== undefined) o2.r2 = o.outerRadius;
		else o2.r2 = o2.r1 + t;
		if (o2.r1 < 0) o2.r1 = 0;
		if (o2.r2 < 0) o2.r2 = 0;
		return o2
	};
	EasyWheel.prototype.brightness = function (c) {
		var r, g, b, brightness;
		if (c.match(/^rgb/)) {
			c = c.match(/rgba?\(([^)]+)\)/)[1];
			c = c.split(/ *, */).map(Number);
			r = c[0];
			g = c[1];
			b = c[2]
		} else if ("#" == c[0] && 7 == c.length) {
			r = parseInt(c.slice(1, 3), 16);
			g = parseInt(c.slice(3, 5), 16);
			b = parseInt(c.slice(5, 7), 16)
		} else if ("#" == c[0] && 4 == c.length) {
			r = parseInt(c[1] + c[1], 16);
			g = parseInt(c[2] + c[2], 16);
			b = parseInt(c[3] + c[3], 16)
		}
		brightness = (r * 299 + g * 587 + b * 114) / 1000;
		if (brightness < 125) {
			return "#fff"
		} else {
			return "#333"
		}
	};
	EasyWheel.prototype.guid = function (r) {
		var t = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",
			a = "";
		r || (r = 8);
		for (var o = 0; o < r; o++) a += t.charAt(Math.floor(Math.random() * t.length));
		return a
	};
	EasyWheel.prototype.randomColor = function () {
		for (var o = "#", r = 0; r < 6; r++) o += "0123456789ABCDEF"[Math.floor(16 * Math.random())];
		return o
	};
	EasyWheel.prototype.FontScale = function (slice) {
		var self = this;
		var Fscale = 1 + 1 * (self.$wheel.width() - parseInt(self.o.width)) / parseInt(self.o.width);
		if (Fscale > 4) {
			Fscale = 4
		} else if (Fscale < 0.1) {
			Fscale = 0.1
		}
		self.$wheel.find(".eWheel-wrapper").css("font-size", Fscale * 100 + "%")
	};
	EasyWheel.prototype.numberToArray = function (N) {
		var args = [];
		var i;
		for (i = 0; i < N; i++) {
			args[i] = i
		}
		return args
	};
	EasyWheel.prototype.totalSlices = function () {
		var self = this;
		return self.items.length
	};
	EasyWheel.prototype.getDegree = function (id) {
		var self = this;
		return 360 / self.totalSlices()
	};
	EasyWheel.prototype.degStart = function (id) {
		var self = this;
		return 360 - self.getDegree() * id
	};
	EasyWheel.prototype.degEnd = function (id) {
		var self = this;
		return 360 - (self.getDegree() * id + self.getDegree())
	};
	EasyWheel.prototype.getRandomInt = function (min, max) {
		return Math.floor(Math.random() * (max - min + 1) + min)
	};
	EasyWheel.prototype.calcSliceSize = function (slice) {
		var self = this;
		var start = self.degStart(slice) - (parseInt(self.o.sliceLineWidth) + 2);
		var end = self.degEnd(slice) + (parseInt(self.o.sliceLineWidth) + 2);
		var results = [];
		results.start = start;
		results.end = end;
		return results
	};
	EasyWheel.prototype.toObject = function (arr) {
		var rv = {};
		for (var i = 0; i < arr.length; ++i)
			if (arr[i] !== undefined) rv[i] = arr[i];
		return rv
	};
	EasyWheel.prototype.WinnerSelector = function () {
		var self = this;
		var obj = {};
		if (typeof self.o.selector !== "string") return false;
		$.each(self.items, function (i, item) {
			if (typeof item[self.o.selector] === "object" || typeof item[self.o.selector] === "array" || typeof item[self.o.selector] === "undefined") return false;
			obj[i] = item[self.o.selector]
		});
		return obj
	};
	EasyWheel.prototype.findWinner = function (value, type) {
		var self = this;
		var obj = undefined;
		if (type !== "custom" && (typeof self.o.selector !== "string" || typeof value === "number")) {
			if (typeof self.items[value] === "undefined") return undefined;
			return value
		}
		$.each(self.items, function (i, item) {
			if (typeof item[self.o.selector] === "object" || typeof item[self.o.selector] === "array" || typeof item[self.o.selector] === "undefined") return undefined;
			if (item[self.o.selector] === value) {
				obj = i
			}
		});
		return obj
	};
	EasyWheel.prototype.selectedSliceID = function (index) {
		var self = this;
		var selector = self.WinnerSelector();
		self.selected = self.o.selected;
		if ($.type(self.selected) === "object") {
			if (typeof self.selected[0] !== "undefined" && self.selected[0].selectedIndex !== undefined) return self.selected[0].selectedIndex
		} else if ($.type(self.selected) === "array") {
			if (self.o.selector !== false) {
				self.selected = $.map(selector, function (value, i) {
					if (value === self.o.selected[index]) return i
				})
			} else {
				self.selected = self.selected[index]
			}
		} else if ($.type(self.selected) === "string" && self.o.selector !== false) {
			self.selected = self.findWinner(self.selected)
		} else if ($.type(self.selected) !== "number") {
			return
		}
		if (typeof self.findWinner(parseInt(self.selected)) === "undefined") return;
		return parseInt(self.selected)
	};
	EasyWheel.prototype.start = function () {
		var self = this;
		self.run()
	};
	EasyWheel.prototype.run = function (selectedWinner) {
		var self = this;
		if (self.inProgress) return;
		if (selectedWinner || selectedWinner === 0) {
			var winner = self.findWinner(selectedWinner, "custom");
			if (typeof winner !== "undefined") {
				self.slice.id = winner
			} else {
				return
			}
		} else {
			if (self.o.max !== 0 && self.counter >= self.o.max) return;
			if (self.o.selector !== false) {
				self.slice.id = self.selectedSliceID(0)
			} else if (self.o.random === true) {
				self.slice.id = self.getRandomInt(0, self.totalSlices() - 1)
			} else {
				return
			}
		}
		self.inProgress = true;
		if (typeof self.items[self.slice.id] === "undefined") return;
		self.slice.results = self.items[self.slice.id];
		self.slice.length = self.slice.id;
		self.o.onStart.call(self.$wheel, self.slice.results, self.spinCount, self.now);
		var selectedSlicePos = self.calcSliceSize(self.slice.id); //var randomize = self.getRandomInt(selectedSlicePos.start, selectedSlicePos.end); //egemen
		var randomize = selectedSlicePos.start + (selectedSlicePos.end - selectedSlicePos.start) / 2;
		var _deg = 360 * parseInt(self.rotates) + randomize;
		self.lastStep = -1;
		self.currentStep = 0;
		var MarkerAnimator = false;
		var MarkerStep;
		var currentSlice = 0;
		var temp = self.numberToArray(self.totalSlices()).reverse();
		if (parseInt(self.o.frame) !== 0) {
			var oldinterval = $.fx.interval;
			$.fx.interval = parseInt(self.o.frame)
		}
		self.spinning = $({
			deg: self.now
		}).animate({
			deg: _deg
		}, {
			duration: parseInt(self.o.duration),
			easing: $.trim(self.o.easing),
			step: function (now, fx) {
				if (parseInt(self.o.frame) !== 0) $.fx.interval = parseInt(self.o.frame);
				self.now = now % 360;
				if ($.trim(self.o.type) !== "color") {
					self.$wheel.find(".eWheel").css({
						"-webkit-transform": "rotate(" + self.now + "deg)",
						"-moz-transform": "rotate(" + self.now + "deg)",
						"-ms-transform": "rotate(" + self.now + "deg)",
						"-o-transform": "rotate(" + self.now + "deg)",
						"transform": "rotate(" + self.now + "deg)"
					})
				}
				self.currentStep = Math.floor(now / (360 / self.totalSlices()));
				self.currentSlice = temp[self.currentStep % self.totalSlices()];
				var ewCircleSize = 400 * 4,
					ewTotalArcs = self.totalSlices(),
					ewArcSizeDeg = 360 / ewTotalArcs,
					ewArcSize = ewCircleSize / ewTotalArcs,
					point = ewCircleSize / 360,
					ewCirclePos = point * self.now,
					ewCirclePosPercent = ewCirclePos / ewCircleSize * 100,
					ewArcPos = (self.currentSlice + 1) * ewArcSize - (ewCircleSize - point * self.now),
					ewArcPosPercent = ewArcPos / ewArcSize * 100,
					cpercent = ewCirclePosPercent,
					apercent = ewArcPosPercent;
				self.slicePercent = ewArcPosPercent;
				self.circlePercent = ewCirclePosPercent;
				self.o.onProgress.call(self.$wheel, self.slicePercent, self.circlePercent);
				if (self.lastStep !== self.currentStep) {
					self.lastStep = self.currentStep;
					if (self.o.markerAnimation === true && $.inArray($.trim(self.o.easing), ["easeInElastic", "easeInBack", "easeInBounce", "easeOutElastic", "easeOutBack", "easeOutBounce", "easeInOutElastic", "easeInOutBack", "easeInOutBounce"]) === -1) {
						var Mduration = parseInt(self.o.duration) / self.totalSlices();
						MarkerStep = -38;
						if (MarkerAnimator) MarkerAnimator.stop();
						MarkerAnimator = $({
							deg: 0
						}).animate({
							deg: MarkerStep
						}, {
							easing: "MarkerEasing",
							duration: Mduration / (360 / 360 * 2),
							step: function (now) {
								$(".eWheel-marker").css({
									"-webkit-transform": "rotate(" + now + "deg)",
									"-moz-transform": "rotate(" + now + "deg)",
									"-ms-transform": "rotate(" + now + "deg)",
									"-o-transform": "rotate(" + now + "deg)",
									"transform": "rotate(" + now + "deg)"
								})
							}
						})
					}
					if ($.trim(self.o.type) === "color") {
						self.$wheel.find("svg>g.ew-slicesGroup>path").each(function (i) {
							$(this).attr("class", "").attr("fill", $(this).attr("data-fill"))
						});
						self.$wheel.find("svg>g.ew-slicesGroup>path").eq(self.currentSlice).attr("class", "ew-ccurrent").attr("fill", self.o.selectedSliceColor);
						self.$wheel.find(".eWheel-txt>.eWheel-title").removeClass("ew-ccurrent");
						self.$wheel.find(".eWheel-txt>.eWheel-title").eq(self.currentSlice).addClass("ew-ccurrent")
					} else {
						self.$wheel.find("svg>g.ew-slicesGroup>path").attr("class", "");
						self.$wheel.find("svg>g.ew-slicesGroup>path").eq(self.currentSlice).attr("class", "ew-current");
						self.$wheel.find(".eWheel-txt>.eWheel-title").removeClass("ew-current");
						self.$wheel.find(".eWheel-txt>.eWheel-title").eq(self.currentSlice).addClass("ew-current")
					}
					self.currentSliceData.id = self.currentSlice;
					self.currentSliceData.results = self.items[self.currentSliceData.id];
					self.currentSliceData.results.length = self.currentSliceData.id;
					self.o.onStep.call(self.$wheel, self.currentSliceData.results, self.slicePercent, self.circlePercent)
				}
				if (parseInt(self.o.frame) !== 0) $.fx.interval = oldinterval
			},
			fail: function (animation, progress, remainingMs) {
				self.inProgress = false;
				self.o.onFail.call(self.$wheel, self.slice.results, self.spinCount, self.now)
			},
			complete: function (animation, progress, remainingMs) {
				self.inProgress = false;
				self.o.onComplete.call(self.$wheel, self.slice.results, self.spinCount, self.now)
			}
		});
		self.counter++;
		self.spinCount++
	};
	EasyWheel.prototype.execute = function () {
		var self = this;
		self.currentSlice = self.totalSlices() - 1;
		self.$wheel.css("font-size", parseInt(self.o.fontSize));
		self.$wheel.width(parseInt(self.o.width));
		self.$wheel.height(self.$wheel.width());
		self.$wheel.find(".eWheel-wrapper").width(self.$wheel.width());
		self.$wheel.find(".eWheel-wrapper").height(self.$wheel.width());
		self.FontScale();
		$(window).on("resize." + self.instanceUid, function () {
			self.$wheel.height(self.$wheel.width());
			self.$wheel.find(".eWheel-wrapper").width(self.$wheel.width());
			self.$wheel.find(".eWheel-wrapper").height(self.$wheel.width());
			self.FontScale()
		})
	};
	$.fn.easyWheel = function () {
		var self = this,
			opt = arguments[0],
			args = Array.prototype.slice.call(arguments, 1),
			arg2 = Array.prototype.slice.call(arguments, 2),
			l = self.length,
			i, apply, allowed = ["destroy", "start", "finish", "option"];
		for (i = 0; i < l; i++) {
			if (typeof opt == "object" || typeof opt == "undefined") {
				self[i].easyWheel = new EasyWheel(self[i], opt)
			} else if ($.inArray($.trim(opt), allowed) !== -1) {
				if ($.trim(opt) === "option") {
					apply = self[i].easyWheel[opt].apply(self[i].easyWheel, args, arg2)
				} else {
					apply = self[i].easyWheel[opt].apply(self[i].easyWheel, args)
				}
			}
			if (typeof apply != "undefined") return apply
		}
		return self
	}
});

function SpinToWin(config) {
	this.config = config;
	if (window.Android || window.BrowserTest) {
		this.convertConfigJson()
	}
	this.container = document.getElementById("container");
	if (this.config.taTemplate == "full_spin") {
		this.wheelContainerId = "wheel-container-full";
		document.getElementById("wheel-container-half").remove();
	} else {
		this.wheelContainerId = "wheel-container-half";
		document.getElementById("wheel-container-full").remove();
	}


	this.wheelContainer = document.getElementById(this.wheelContainerId);
	this.closeButton = document.getElementById("spin-to-win-box-close");
	this.titleElement = document.getElementById("form-title");
	this.messageElement = document.getElementById("form-message");
	this.submitButton = document.getElementById("form-submit-btn");
	this.emailInput = document.getElementById("vl-form-input");
	this.consentContainer = document.getElementById("vl-form-consent");
	this.emailPermitContainer = document.getElementById("vl-permitform-email");
	this.consentCheckbox = document.getElementById("vl-form-checkbox");
	this.emailPermitCheckbox = document.getElementById("vl-form-checkbox-emailpermit");
	this.consentText = document.getElementById("vl-form-consent-text");
	this.emailPermitText = document.getElementById("vl-permitform-email-text");
	this.couponCode = document.getElementById("coupon-code");
	this.copyButton = document.getElementById("form-copy-btn");
	this.warning = document.getElementById("vl-warning");
	this.invalidEmailMessageLi = document.getElementById("invalid-email-message");
	this.checkConsentMessageLi = document.getElementById("check-consent-message");
	this.successMessageElement = document.getElementById("success-message");
	this.promocodeTitleElement = document.getElementById("promocode-title");

	this.promocodesSoldoutMessageElement = document.getElementById("promocodes_soldout_message");

	this.formValidation = {
		email: true,
		consent: true
	};
	this.won = false;
	this.spinCompleted = false;
	this.easyWheelInitialized = false;
	this.config.windowWidth = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;
	this.config.statusBarHeight = window.screen.height - window.innerHeight;
	this.config.windowHeightWidthRatio = window.innerHeight / window.innerWidth;
	if (this.config.taTemplate == "full_spin") {
		this.config.wheelContainerMarginLeft = this.config.windowHeightWidthRatio > 1.6 ? (window.innerWidth / 6) : (window.innerWidth / 5);
		this.config.r = parseFloat(window.innerWidth / 2) - this.config.wheelContainerMarginLeft;
		this.config.wheelContainerWidth = this.config.windowWidth - this.config.wheelContainerMarginLeft * 2
	} else {
		this.config.wheelContainerMarginLeft = 0;
		this.config.r = parseFloat(window.innerWidth / 2);
		this.config.wheelContainerWidth = this.config.windowWidth
	}
	this.config.selectedPromotionCode = "";
	this.convertStringsToNumber();
	this.setCloseButton();
	this.config.mailFormEnabled = config.mailSubscription;

	this.setContent();
	this.styleHandler();
	this.addFonts();
	this.setFonts();
	window.onresize = function () {
		window.spinToWin.styleHandler();
		window.spinToWin.setFonts();
	};
	window.spinToWin = this;
	this.createItems();
	this.createEasyWheel();

	if (this.config.taTemplate == "full_spin") {
		this.config.wheelContainerMarginLeft = this.config.wheelContainerMarginLeft - window.innerWidth * 0.06;
		this.wheelContainer.style.marginLeft = this.config.wheelContainerMarginLeft + "px";
	}

	this.handleVisibility()
	var rotates = 4;
	this.config.totalSliceCount = this.config.items.length * rotates;
	this.config.mailFormSubmitCompleted = false;
	this.checkAvailability();



};

SpinToWin.prototype.checkAvailability = function () {
	var availableSliceCount = 0;
	for (var i = 0; i < this.config.slices.length; i++) {
		if (this.config.slices[i].type == "staticcode") {
			availableSliceCount++;
		} else if (this.config.slices[i].type == "promotion" && this.config.slices[i].is_available) {
			availableSliceCount++;
		}
	}
	if (availableSliceCount == 0) {
		this.showSoldout();
	}
};

SpinToWin.prototype.showSoldout = function () {
	window.spinToWin.submitButton.removeEventListener("click", window.spinToWin.submit);
	window.spinToWin.wheelContainer.removeEventListener("swiped-right", window.spinToWin.startSpin);
	var vl_form_input = document.getElementById("vl-form-input");
	if (vl_form_input !== null) vl_form_input.setAttribute("disabled", "");
	var vl_form_checkbox = document.getElementById("vl-form-checkbox");
	if (vl_form_checkbox !== null) vl_form_checkbox.setAttribute("disabled", "");
	var vl_form_checkbox_emailpermit = document.getElementById("vl-form-checkbox-emailpermit");
	if (vl_form_checkbox_emailpermit !== null) vl_form_checkbox_emailpermit.setAttribute("disabled", "");
	var vl_form_submit_btn = document.getElementsByClassName("form-submit-btn");
	if (vl_form_submit_btn !== null) vl_form_submit_btn[0].classList.add("disabled");
	window.spinToWin.promocodesSoldoutMessageElement.style.display = "block";
};

SpinToWin.prototype.createItems = function () {
	this.config.items = [];
	var i = 0;
	for (; i < this.config.slices.length; i++) {
		this.config.items.push({
			id: i,
			name: window.spinToWin.breakString(this.config.slices[i].displayName, 10),
			color: this.config.slices[i].color,
			code: this.config.slices[i].code,
			type: this.config.slices[i].type,
			win: false
		})
	}
	if (this.config.sliceCount > this.config.slices.length) {
		while (this.config.items.length < this.config.sliceCount) {
			var sliceId = i % this.config.slices.length;
			this.config.items.push({
				id: i,
				name: window.spinToWin.breakString(this.config.slices[sliceId].displayName, 10),
				color: this.config.slices[sliceId].color,
				code: this.config.slices[sliceId].code,
				type: this.config.slices[sliceId].type,
				win: false
			});
			i++
		}
	}
};
SpinToWin.prototype.createEasyWheel = function () {
	$("#" + this.wheelContainerId).easyWheel({
		items: window.spinToWin.config.items,
		duration: 1,
		rotates: 4,
		frame: 1,
		easing: "easyWheel",
		type: "spin",
		width: window.spinToWin.config.wheelContainerWidth,
		fontSize: window.spinToWin.config.displaynameTextSize + 8,
		textOffset: 8,
		letterSpacing: 0,
		textLine: "v",
		textArc: true,
		outerLineWidth: 5,
		centerImage: window.spinToWin.config.img,
		centerWidth: 20,
		centerLineWidth: 5,
		centerImageWidth: 20,
		textColor: window.spinToWin.config.displaynameTextColor,
		markerColor: window.spinToWin.config.buttonColor,
		centerLineColor: "#ffffff",
		centerBackground: "#ffffff",
		sliceLineColor: "#ffffff",
		outerLineColor: "#ffffff",
		onStep: function (item, slicePercent, circlePercent) {
			if (window.spinToWin.easyWheelInitialized && window.spinToWin.config.completedStepCount < window.spinToWin.config.totalSliceCount) {
				if (window.spinToWin.easyWheelInitialized && window.spinToWin.config.completedStepCount < 1
					&& window.spinToWin.config.wheelSpinAction == "swipe") {
					window.spinToWin.wheelContainer.removeEventListener("swiped-right", window.spinToWin.startSpin);
				}
				window.spinToWin.playTick();
				window.spinToWin.config.completedStepCount = window.spinToWin.config.completedStepCount + 1;
			} else {
				window.spinToWin.config.completedStepCount = 0;
			}
		},
		onStart: function (results, spinCount, now) { },
		onComplete: function (results, count, now) {
			if (!window.spinToWin.easyWheelInitialized) {
				window.spinToWin.easyWheelInitialized = true;
				window.easyWheel.items[0].win = false;
				window.easyWheel.o.duration = 6000
			} else {
				window.spinToWin.resultHandler(results)
			}
		}
	});
	window.easyWheel.items[0].win = true;
	window.easyWheel.start()
};
SpinToWin.prototype.convertConfigJson = function () {
	//actiondata

	this.config.promocodesSoldoutMessage = this.config.actiondata.promocodes_soldout_message;
	this.config.mailSubscription = this.config.actiondata.mail_subscription;
	this.config.sliceCount = this.config.actiondata.slice_count;
	this.config.slices = this.config.actiondata.slices.map(slice => ({
		...slice
		, isAvailable: slice.isAvailable === undefined ? slice.is_available : slice.isAvailable
	}));

	this.config.img = this.config.actiondata.img;
	this.config.taTemplate = this.config.actiondata.taTemplate;
	this.config.promocodeTitle = this.config.actiondata.promocode_title;
	this.config.wheelSpinAction = this.config.actiondata.wheel_spin_action;
	this.config.copyButtonLabel = this.config.actiondata.copybutton_label;

	//spin_to_win_content
	this.config.title = this.config.actiondata.spin_to_win_content.title;
	this.config.message = this.config.actiondata.spin_to_win_content.message;
	this.config.placeholder = this.config.actiondata.spin_to_win_content.placeholder;
	this.config.buttonLabel = this.config.actiondata.spin_to_win_content.button_label;
	this.config.consentText = this.config.actiondata.spin_to_win_content.consent_text;
	this.config.emailPermitText = this.config.actiondata.spin_to_win_content.emailpermit_text;
	this.config.successMessage = this.config.actiondata.spin_to_win_content.success_message;
	this.config.invalidEmailMessage = this.config.actiondata.spin_to_win_content.invalid_email_message;
	this.config.checkConsentMessage = this.config.actiondata.spin_to_win_content.check_consent_message;

	//ExtendedProps
	var extendedProps = JSON.parse(decodeURIComponent(this.config.actiondata.ExtendedProps));
	this.config.displaynameTextColor = extendedProps.displayname_text_color;
	this.config.displaynameFontFamily = extendedProps.displayname_font_family;
	this.config.displaynameTextSize = extendedProps.displayname_text_size;
	this.config.titleTextColor = extendedProps.title_text_color;
	this.config.titleFontFamily = extendedProps.title_font_family;
	this.config.titleTextSize = extendedProps.title_text_size;
	this.config.textColor = extendedProps.text_color;
	this.config.textFontFamily = extendedProps.text_font_family;
	this.config.textSize = extendedProps.text_size;
	this.config.buttonColor = extendedProps.button_color;
	this.config.buttonTextColor = extendedProps.button_text_color;
	this.config.buttonFontFamily = extendedProps.button_font_family;
	this.config.buttonTextSize = extendedProps.button_text_size;
	this.config.promocodeTitleTextColor = extendedProps.promocode_title_text_color;
	this.config.promocodeTitleFontFamily = extendedProps.promocode_title_font_family;
	this.config.promocodeTitleTextSize = extendedProps.promocode_title_text_size;
	this.config.promocodeBackgroundColor = extendedProps.promocode_background_color;
	this.config.promocodeTextColor = extendedProps.promocode_text_color;
	this.config.copybuttonColor = extendedProps.copybutton_color;
	this.config.copybuttonTextColor = extendedProps.copybutton_text_color;
	this.config.copybuttonFontFamily = extendedProps.copybutton_font_family;
	this.config.copybuttonTextSize = extendedProps.copybutton_text_size;
	this.config.emailpermitTextSize = extendedProps.emailpermit_text_size;
	this.config.emailpermitTextUrl = extendedProps.emailpermit_text_url;
	this.config.consentTextSize = extendedProps.consent_text_size;
	this.config.consentTextUrl = extendedProps.consent_text_url;
	this.config.closeButtonColor = extendedProps.close_button_color;
	this.config.backgroundColor = extendedProps.background_color;

	this.config.promocodesSoldoutMessageTextColor = extendedProps.promocodes_soldout_message_text_color;
	this.config.promocodesSoldoutMessageFontFamily = extendedProps.promocodes_soldout_message_font_family;
	this.config.promocodesSoldoutMessageTextSize = extendedProps.promocodes_soldout_message_text_size;
	this.config.promocodesSoldoutMessageBackgroundColor = extendedProps.promocodes_soldout_message_background_color;

	this.config.displaynameCustomFontFamilyAndroid = extendedProps.displayname_custom_font_family_android;
	this.config.titleCustomFontFamilyAndroid = extendedProps.title_custom_font_family_android;
	this.config.textCustomFontFamilyAndroid = extendedProps.text_custom_font_family_android;
	this.config.buttonCustomFontFamilyAndroid = extendedProps.button_custom_font_family_android;
	this.config.promocodeTitleCustomFontFamilyAndroid = extendedProps.promocode_title_custom_font_family_android;
	this.config.copybuttonCustomFontFamilyAndroid = extendedProps.copybutton_custom_font_family_android;
	this.config.promocodesSoldoutMessageCustomFontFamilyAndroid = extendedProps.promocodes_soldout_message_custom_font_family_android;

	//position
	this.config.titlePosition = extendedProps.title_position;
	this.config.textPosition = extendedProps.text_position;
	this.config.buttonPosition = extendedProps.button_position;
	this.config.copybuttonPosition = extendedProps.copybutton_position;

	//promocodeBanner
	this.config.promocodeBannerText = extendedProps.promocode_banner_text;
	this.config.promocodeBannerTextColor = extendedProps.promocode_banner_text_color;
	this.config.promocodeBannerBackgroundColor = extendedProps.promocode_banner_background_color;
	this.config.promocodeBannerButtonLabel = extendedProps.promocode_banner_button_label;
};
SpinToWin.prototype.addFonts = function () {
	if (this.config.fontFiles === undefined) {
		return
	}
	var addedFontFiles = [];
	for (var fontFileIndex in this.config.fontFiles) {
		var fontFile = this.config.fontFiles[fontFileIndex];
		if (addedFontFiles.includes(fontFile)) {
			continue;
		}
		var fontFamily = fontFile.split(".")[0];
		var newStyle = document.createElement('style');
		var cssContent = "@font-face{font-family:" + fontFamily + ";src:url('" + fontFile + "');}";
		newStyle.appendChild(document.createTextNode(cssContent));
		document.head.appendChild(newStyle);
		addedFontFiles.push(fontFile);
	}
};

SpinToWin.prototype.setFonts = function () {
	var isIos = window.webkit && window.webkit.messageHandlers;

	if (typeof this.config.displaynameFontFamily === "string" && this.config.displaynameFontFamily.toLowerCase() === "custom") {
		this.wheelContainer.style.fontFamily = isIos ? this.config.displaynameCustomFontFamilyIos : this.config.displaynameCustomFontFamilyAndroid;
	}
	if (typeof this.config.titleFontFamily === "string" && this.config.titleFontFamily.toLowerCase() === "custom") {
		this.titleElement.style.fontFamily = isIos ? this.config.titleCustomFontFamilyIos : this.config.titleCustomFontFamilyAndroid;
	}
	if (typeof this.config.textFontFamily === "string" && this.config.textFontFamily.toLowerCase() === "custom") {
		this.messageElement.style.fontFamily = isIos ? this.config.textCustomFontFamilyIos : this.config.textCustomFontFamilyAndroid;
		this.consentText.style.fontFamily = isIos ? this.config.textCustomFontFamilyIos : this.config.textCustomFontFamilyAndroid;
		this.emailPermitText.style.fontFamily = isIos ? this.config.textCustomFontFamilyIos : this.config.textCustomFontFamilyAndroid;
		this.invalidEmailMessageLi.style.fontFamily = isIos ? this.config.textCustomFontFamilyIos : this.config.textCustomFontFamilyAndroid;
		this.checkConsentMessageLi.style.fontFamily = isIos ? this.config.textCustomFontFamilyIos : this.config.textCustomFontFamilyAndroid;
		this.emailInput.style.fontFamily = isIos ? this.config.textCustomFontFamilyIos : this.config.textCustomFontFamilyAndroid;
	}
	if (typeof this.config.buttonFontFamily === "string" && this.config.buttonFontFamily.toLowerCase() === "custom") {
		this.submitButton.style.fontFamily = isIos ? this.config.buttonCustomFontFamilyIos : this.config.buttonCustomFontFamilyAndroid;
	}
	if (typeof this.config.promocodeTitleFontFamily === "string" && this.config.promocodeTitleFontFamily.toLowerCase() === "custom") {
		this.promocodeTitleElement.style.fontFamily = isIos ? this.config.promocodeTitleCustomFontFamilyIos : this.config.promocodeTitleCustomFontFamilyAndroid;
	}
	if (typeof this.config.copybuttonFontFamily === "string" && this.config.copybuttonFontFamily.toLowerCase() === "custom") {
		this.copyButton.style.fontFamily = isIos ? this.config.copybuttonCustomFontFamilyIos : this.config.copybuttonCustomFontFamilyAndroid;
		this.couponCode.style.fontFamily = isIos ? this.config.copybuttonCustomFontFamilyIos : this.config.copybuttonCustomFontFamilyAndroid;
	}
	if (typeof this.config.promocodesSoldoutMessageFontFamily === "string" && this.config.promocodesSoldoutMessageFontFamily.toLowerCase() === "custom") {
		this.promocodesSoldoutMessageElement.style.fontFamily = isIos ? this.config.promocodesSoldoutMessageCustomFontFamilyIos : this.config.promocodesSoldoutMessageCustomFontFamilyAndroid;
	}

};

SpinToWin.prototype.getPromotionCode = function () {
	if (window.Android) {
		Android.getPromotionCode()
	} else if (window.webkit && window.webkit.messageHandlers) {
		window.webkit.messageHandlers.eventHandler.postMessage({
			method: "getPromotionCode"
		})
	} else {
		window.BrowserTest.getPromotionCode()
	}
};
SpinToWin.prototype.subscribeEmail = function () {
	if (window.Android) {
		Android.subscribeEmail(this.emailInput.value.trim())
	} else if (window.webkit && window.webkit.messageHandlers) {
		window.webkit.messageHandlers.eventHandler.postMessage({
			method: "subscribeEmail",
			email: this.emailInput.value.trim()
		})
	}
};
SpinToWin.prototype.close = function () {
	if (window.Android) {
		Android.close()
	} else if (window.webkit && window.webkit.messageHandlers) {
		window.webkit.messageHandlers.eventHandler.postMessage({
			method: "close"
		})
	}
};
SpinToWin.prototype.copyToClipboard = function () {
	if (window.Android) {
		Android.copyToClipboard(this.couponCode.innerText)
	} else if (window.webkit.messageHandlers.eventHandler) {
		window.webkit.messageHandlers.eventHandler.postMessage({
			method: "copyToClipboard",
			couponCode: this.couponCode.innerText
		})
	}
};
SpinToWin.prototype.sendReport = function () {
	if (window.Android) {
		Android.sendReport()
	} else if (window.webkit && window.webkit.messageHandlers) {
		window.webkit.messageHandlers.eventHandler.postMessage({
			method: "sendReport"
		})
	}
};
SpinToWin.prototype.openUrl = function (url) {
	if (window.webkit && window.webkit.messageHandlers) {
		window.webkit.messageHandlers.eventHandler.postMessage({
			method: "openUrl",
			url: url
		})
	}
};
SpinToWin.prototype.convertStringsToNumber = function () {
	this.config.displaynameTextSize = isNaN(parseInt(this.config.displaynameTextSize)) ? 10 : parseInt(this.config.displaynameTextSize);
	this.config.titleTextSize = isNaN(parseInt(this.config.titleTextSize)) ? 10 : parseInt(this.config.titleTextSize);
	this.config.textSize = isNaN(parseInt(this.config.textSize)) ? 5 : parseInt(this.config.textSize);
	this.config.buttonTextSize = isNaN(parseInt(this.config.buttonTextSize)) ? 20 : parseInt(this.config.buttonTextSize);
	this.config.consentTextSize = isNaN(parseInt(this.config.consentTextSize)) ? 5 : parseInt(this.config.consentTextSize);
	this.config.copybuttonTextSize = isNaN(parseInt(this.config.copybuttonTextSize)) ? 20 : parseInt(this.config.copybuttonTextSize);
	this.config.promocodeTitleTextSize = isNaN(parseInt(this.config.promocodeTitleTextSize)) ? 20 : parseInt(this.config.promocodeTitleTextSize);
	this.config.promocodesSoldoutMessageTextSize = isNaN(parseInt(this.config.promocodesSoldoutMessageTextSize)) ? 20 : parseInt(this.config.promocodesSoldoutMessageTextSize);
};

SpinToWin.prototype.setContent = function () {
	this.container.style.backgroundColor = this.config.backgroundColor;
	this.titleElement.innerHTML = this.config.title.replace(/\\n/g, "<br/>");
	this.titleElement.style.color = this.config.titleTextColor;
	this.titleElement.style.fontFamily = this.config.titleFontFamily;
	this.titleElement.style.fontSize = (this.config.titleTextSize + 20) + "px";
	this.messageElement.innerHTML = this.config.message.replace(/\\n/g, "<br/>");
	this.messageElement.style.color = this.config.textColor;
	this.messageElement.style.fontFamily = this.config.textFontFamily;
	this.messageElement.style.fontSize = (this.config.textSize + 10) + "px";
	this.emailInput.style.fontFamily = this.config.textFontFamily;
	this.emailInput.style.fontSize = (this.config.textSize + 10) + "px";
	this.submitButton.innerHTML = this.config.buttonLabel;
	this.submitButton.style.color = this.config.buttonTextColor;
	this.submitButton.style.backgroundColor = this.config.buttonColor;
	this.submitButton.style.fontFamily = this.config.buttonFontFamily;
	this.submitButton.style.fontSize = (this.config.buttonTextSize + 20) + "px";
	this.emailInput.placeholder = this.config.placeholder;
	this.consentText.innerHTML = this.prepareCheckboxHtmls(this.config.consentText, this.config.consentTextUrl);
	this.consentText.style.fontSize = (this.config.consentTextSize + 10) + "px";
	this.consentText.style.fontFamily = this.config.textFontFamily;
	this.emailPermitText.innerHTML = this.prepareCheckboxHtmls(this.config.emailPermitText, this.config.emailpermitTextUrl);
	this.emailPermitText.style.fontSize = (this.config.consentTextSize + 10) + "px";
	this.emailPermitText.style.fontFamily = this.config.textFontFamily;
	this.copyButton.innerHTML = this.config.copyButtonLabel;
	this.copyButton.style.color = this.config.copybuttonTextColor;
	this.copyButton.style.backgroundColor = this.config.copybuttonColor;
	this.copyButton.style.fontFamily = this.config.copybuttonFontFamily;
	this.copyButton.style.fontSize = (this.config.copybuttonTextSize + 20) + "px";
	this.invalidEmailMessageLi.innerHTML = this.config.invalidEmailMessage;
	this.invalidEmailMessageLi.style.fontSize = (this.config.consentTextSize + 10) + "px";
	this.invalidEmailMessageLi.style.fontFamily = this.config.textFontFamily;
	this.checkConsentMessageLi.innerHTML = this.config.checkConsentMessage;
	this.checkConsentMessageLi.style.fontSize = (this.config.consentTextSize + 10) + "px";
	this.checkConsentMessageLi.style.fontFamily = this.config.textFontFamily;
	this.couponCode.style.color = this.config.promocodeTextColor;
	this.couponCode.style.backgroundColor = this.config.promocodeBackgroundColor;
	this.couponCode.style.fontFamily = this.config.copybuttonFontFamily;
	this.couponCode.style.fontSize = (this.config.copybuttonTextSize + 20) + "px";
	this.successMessageElement.innerHTML = this.config.successMessage.replace(/\\n/g, "<br/>");
	this.successMessageElement.style.color = "green";
	this.promocodeTitleElement.innerHTML = this.config.promocodeTitle.replace(/\\n/g, "<br/>");
	this.promocodeTitleElement.style.color = this.config.promocodeTitleTextColor;
	this.promocodeTitleElement.style.fontFamily = this.config.promocodeTitleFontFamily;
	this.promocodeTitleElement.style.fontSize = (this.config.promocodeTitleTextSize + 20) + "px";

	if (this.config.promocodesSoldoutMessage !== undefined && this.config.promocodesSoldoutMessage.length > 0) {
		this.promocodesSoldoutMessageElement.innerHTML = this.config.promocodesSoldoutMessage.replace(/\\n/g, "<br/>");
	}

	this.promocodesSoldoutMessageElement.style.color = this.config.promocodesSoldoutMessageTextColor;
	this.promocodesSoldoutMessageElement.style.fontFamily = this.config.promocodesSoldoutMessageFontFamily;
	this.promocodesSoldoutMessageElement.style.fontSize = (this.config.promocodesSoldoutMessageTextSize + 20) + "px";
	this.promocodesSoldoutMessageElement.style.backgroundColor = this.config.promocodesSoldoutMessageBackgroundColor;

	if (this.config.taTemplate == "full_spin") {
		this.handlePositions();
	}

	this.container.addEventListener("click", function (event) {
		if (event.target.tagName != "INPUT") {
			document.activeElement.blur()
		}
	});
	this.emailInput.addEventListener("keypress", function (event) {
		if (event.key === 'Enter') {
			document.activeElement.blur()
		}
	});
	if (this.config.wheelSpinAction == "swipe") {
		if (this.config.mailFormEnabled) {
			this.submitButton.addEventListener("click", this.submit);
		} else {
			this.wheelContainer.addEventListener('swiped-right', this.startSpin);
		}
	} else {
		this.submitButton.addEventListener("click", this.submit);
	}
	this.closeButton.addEventListener("click", evt => this.close());
	this.copyButton.addEventListener("click", evt => this.copyToClipboard());
};

SpinToWin.prototype.handlePositions = function () {
	if (this.config.titlePosition == "bottom") {
		this.titleElement.remove();
		this.wheelContainer.parentNode.insertBefore(this.titleElement, this.wheelContainer.nextSibling);
		this.titleElement.style.marginTop = window.innerWidth * 0.88 + "px";
		if (this.config.textPosition == "bottom") {
			this.messageElement.remove();
			this.titleElement.parentNode.insertBefore(this.messageElement, this.titleElement.nextSibling);
			if (this.config.buttonPosition == "bottom") {
				this.submitButton.remove();
				this.messageElement.parentNode.insertBefore(this.submitButton, this.messageElement.nextSibling);
			}
			if (this.config.copybuttonPosition == "bottom") {
				this.copyButton.remove();
				this.messageElement.parentNode.insertBefore(this.copyButton, this.messageElement.nextSibling);
				this.copyButton.style.marginBottom = "60px";
			}
		} else {
			this.submitButton.remove();
			this.titleElement.parentNode.insertBefore(this.submitButton, this.titleElement.nextSibling);
			if (this.config.copybuttonPosition == "bottom") {
				this.copyButton.remove();
				this.titleElement.parentNode.insertBefore(this.copyButton, this.titleElement.nextSibling);
				this.copyButton.style.marginBottom = "60px";
			}
		}
	} else if (this.config.textPosition == "bottom") {
		this.messageElement.remove();
		this.wheelContainer.parentNode.insertBefore(this.messageElement, this.wheelContainer.nextSibling);
		this.messageElement.style.marginTop = window.innerWidth * 0.88 + "px";
		if (this.config.buttonPosition == "bottom") {
			this.submitButton.remove();
			this.messageElement.parentNode.insertBefore(this.submitButton, this.messageElement.nextSibling);
		}
		if (this.config.copybuttonPosition == "bottom") {
			this.copyButton.remove();
			this.messageElement.parentNode.insertBefore(this.copyButton, this.messageElement.nextSibling);
			this.copyButton.style.marginBottom = "60px";
		}
	} else if (this.config.buttonPosition == "bottom") {
		this.submitButton.remove();
		this.wheelContainer.parentNode.insertBefore(this.submitButton, this.wheelContainer.nextSibling);
		this.submitButton.style.marginTop = window.innerWidth * 0.88 + "px";
		if (this.config.copybuttonPosition == "bottom") {
			this.copyButton.remove();
			this.submitButton.parentNode.insertBefore(this.copyButton, this.submitButton.nextSibling);
			this.copyButton.style.marginTop = window.innerWidth * 0.88 + "px";
			this.copyButton.style.marginBottom = "60px";
		}
	} else if (this.config.copybuttonPosition == "bottom") {
		this.copyButton.remove();
		this.wheelContainer.parentNode.insertBefore(this.copyButton, this.wheelContainer.nextSibling);
		this.copyButton.style.marginTop = window.innerWidth * 0.88 + "px";
		this.copyButton.style.marginBottom = "60px";
	}
};

SpinToWin.prototype.validateForm = function () {
	var result = {
		email: true,
		consent: true
	};
	if (!this.validateEmail(this.emailInput.value)) {
		result.email = false
	}
	if (!this.isNullOrWhitespace(this.consentText.innerText)) {
		result.consent = this.consentCheckbox.checked
	}
	if (result.consent) {
		if (!this.isNullOrWhitespace(this.emailPermitText.innerText)) {
			result.consent = this.emailPermitCheckbox.checked
		}
	}
	this.formValidation = result;
	return result
};

SpinToWin.prototype.handleVisibility = function () {
	if (this.spinCompleted) {
		this.couponCode.style.display = "";
		this.emailInput.style.display = "none";
		this.submitButton.style.display = "none";
		this.consentContainer.style.display = "none";
		this.emailPermitContainer.style.display = "none";
		this.warning.style.display = "none";
		if (this.won) {
			this.promocodeTitleElement.style.display = "";
			this.copyButton.style.display = ""
		} else {
			this.promocodeTitleElement.style.display = "none";
			this.copyButton.style.display = "none"
		}
		if (this.config.mailFormEnabled) {
			this.successMessageElement.style.display = ""
		} else {
			this.successMessageElement.style.display = "none"
		}
		return
	} else {
		this.couponCode.style.display = "none";
		this.copyButton.style.display = "none";
		this.successMessageElement.style.display = "none";
		this.promocodeTitleElement.style.display = "none"
	}
	this.warning.style.display = "none";
	if (this.config.mailFormEnabled) {
		if (!this.formValidation.email || !this.formValidation.consent) {
			this.warning.style.display = "";
			if (this.formValidation.email) {
				this.invalidEmailMessageLi.style.display = "none"
			} else {
				this.invalidEmailMessageLi.style.display = ""
			}
			if (this.formValidation.consent) {
				this.checkConsentMessageLi.style.display = "none"
			} else {
				this.checkConsentMessageLi.style.display = ""
			}
		} else {
			this.warning.style.display = "none"
		}
		if (this.isNullOrWhitespace(this.consentText.innerHTML)) {
			this.consentCheckbox.style.display = "none";
			this.consentContainer.style.display = "none"
		}
		if (this.isNullOrWhitespace(this.emailPermitText.innerHTML)) {
			this.emailPermitCheckbox.style.display = "none";
			this.emailPermitContainer.style.display = "none"
		}
		if (this.config.mailFormSubmitCompleted) {
			this.successMessageElement.style.display = "";
			this.emailInput.style.display = "none";
			this.submitButton.style.display = "none";
			this.consentContainer.style.display = "none";
			this.emailPermitContainer.style.display = "none";
			this.warning.style.display = "none";
		}
	} else {
		if(this.config.taTemplate == "full_spin") {
			document.getElementById("wl_custom_fields_holder").style.display = "table";
		}

		this.emailInput.style.display = "none";
		this.consentContainer.style.display = "none";
		this.emailPermitContainer.style.display = "none";
		this.emailPermitContainer.height = "0px";
		if (this.config.wheelSpinAction == "swipe") {
			this.submitButton.style.display = "none";
		}
	}
};
SpinToWin.prototype.getWheelContainerMarginTop = function () {
	var marginTop = 10;
	if (window.innerHeight < 750) {
		marginTop = 10;
	} else if (window.innerHeight < 1000) {
		marginTop = 30;
	} else {
		marginTop = 50;
	}

	if (this.config.taTemplate == "full_spin") {
		marginTop = marginTop + 15;
	}

	return marginTop + "px";
};
SpinToWin.prototype.styleHandler = function () {
	this.wheelContainer.style.position = "absolute";
	this.wheelContainer.style.fontFamily = this.config.displaynameFontFamily;
	this.wheelContainer.style.marginLeft = this.config.wheelContainerMarginLeft + "px";
	if (window.Android) {
		if (this.config.taTemplate == "full_spin") {
			this.wheelContainer.style.marginTop = this.getWheelContainerMarginTop();
		} else {
			this.wheelContainer.style.bottom = -this.config.r + "px"
		}
	} else {
		if (this.config.taTemplate == "full_spin") {
			this.wheelContainer.style.marginTop = this.getWheelContainerMarginTop();
		} else {
			this.wheelContainer.style.bottom = -this.config.r + this.config.statusBarHeight + "px"
		}
	}

	var styleEl = document.createElement("style"),
		styleString = "#" + this.wheelContainerId + "{float:left;width:" + config.r
			+ "px;height:" + (2 * this.config.r) + "px}@media only screen and (max-width:2500px){"
			+ "#" + this.wheelContainerId + "{float:unset;width:100%;text-align:center;position:relative}" + "}";

	styleEl.id = "rd-styles";
	if (!document.getElementById("rd-styles")) {
		styleEl.innerHTML = styleString;
		document.head.appendChild(styleEl);
	} else {
		document.getElementById("rd-styles").innerHTML = styleString;
	}
};
SpinToWin.prototype.submit = function () {
	if (config.mailFormEnabled) {
		this.formValidation = window.spinToWin.validateForm();
		if (!window.spinToWin.formValidation.email || !window.spinToWin.formValidation.consent) {
			window.spinToWin.handleVisibility();
			return;
		}
		window.spinToWin.subscribeEmail();
	}
	window.spinToWin.submitButton.removeEventListener("click", window.spinToWin.submit);
	window.spinToWin.config.mailFormSubmitCompleted = true;
	window.spinToWin.handleVisibility();
	if (config.wheelSpinAction == "swipe") {
		window.spinToWin.wheelContainer.addEventListener("swiped-right", window.spinToWin.startSpin);
	} else {
		window.spinToWin.startSpin();
	}
};
SpinToWin.prototype.startSpin = function () {
	window.spinToWin.sendReport();
	window.spinToWin.wheelContainer.removeEventListener("swiped-right", window.spinToWin.startSpin);
	window.spinToWin.getPromotionCode();
};
SpinToWin.prototype.spin = function (sliceIndex, promotionCode) {
	if (sliceIndex > -1) {
		window.spinToWin.won = true;
		window.spinToWin.config.items[sliceIndex].win = true;
		window.spinToWin.config.items[sliceIndex].code = promotionCode
	} else {
		var staticCodeSliceIndexes = [];
		for (var i = 0; i < window.spinToWin.config.items.length; i++) {
			if (window.spinToWin.config.items[i].type === "staticcode") {
				staticCodeSliceIndexes.push(i)
			}
		}
		if (staticCodeSliceIndexes.length > 0) {
			window.spinToWin.won = true;
			sliceIndex = staticCodeSliceIndexes[this.randomInt(0, staticCodeSliceIndexes.length)]
		} else {
			window.spinToWin.showSoldout();
			return;
		}
	}
	window.spinToWin.spinHandler(sliceIndex)
};
SpinToWin.prototype.spinHandler = function (result) {
	var vl_form_input = document.getElementById("vl-form-input");
	if (vl_form_input !== null) vl_form_input.setAttribute("disabled", "");
	var vl_form_checkbox = document.getElementById("vl-form-checkbox");
	if (vl_form_checkbox !== null) vl_form_checkbox.setAttribute("disabled", "");
	var vl_form_checkbox_emailpermit = document.getElementById("vl-form-checkbox-emailpermit");
	if (vl_form_checkbox_emailpermit !== null) vl_form_checkbox_emailpermit.setAttribute("disabled", "");
	var vl_form_submit_btn = document.getElementsByClassName("form-submit-btn");
	if (vl_form_submit_btn !== null) vl_form_submit_btn[0].classList.add("disabled");
	window.spinToWin.config.items[result].win = true;
	window.easyWheel.items[result].win = true;
	window.easyWheel.start(); // TODO:
};
SpinToWin.prototype.resultHandler = function (res) {
	this.spinCompleted = true;
	if (this.won) {
		this.promocodeTitleElement.innerHTML = this.promocodeTitleElement.innerHTML + "<br/>" + res.name;
		this.couponCode.innerText = res.code;
		this.couponCode.value = res.code
	} else {
		this.promocodeTitleElement.innerHTML = this.promocodeTitleElement.innerHTML + "<br/>" + res.name;
		this.couponCode.innerText = res.name;
		this.couponCode.value = res.name
	}
	this.handleVisibility()
}; //Helper functions
SpinToWin.prototype.breakString = function (str, limit) {
	let brokenString = "";
	for (let i = 0, count = 0; i < str.length; i++) {
		if (count >= limit && str[i] === " ") {
			count = 0;
			brokenString += "<br>"
		} else {
			count++;
			brokenString += str[i]
		}
	}
	return brokenString
};
SpinToWin.prototype.prepareCheckboxHtmls = function (text, url) {
	if (this.isNullOrWhitespace(text)) {
		return ""
	} else if (this.isNullOrWhitespace(url)) {
		return text.replace(new RegExp("<LINK>", "gm"), "").replace(new RegExp("</LINK>", "gm"), "")
	} else if (!text.includes("<LINK>")) {
		if (window.webkit && window.webkit.messageHandlers.eventHandler) {
			return "<a href=\"javascript:window.spinToWin.openUrl('" + url + "')\">" + text + "</a>"
		} else {
			return "<a href=\"" + url + "\">" + text + "</a>"
		}
	} else {
		var linkRegex = /<LINK>(.*?)<\/LINK>/g;
		var regexResult;
		while ((regexResult = linkRegex.exec(text)) !== null) {
			var outerHtml = regexResult[0];
			var innerHtml = regexResult[1];
			if (window.webkit && window.webkit.messageHandlers.eventHandler) {
				var link = "<a href=\"javascript:window.spinToWin.openUrl('" + url + "')\">" + innerHtml + "</a>";
				text = text.replace(outerHtml, link)
			} else {
				var link = "<a href=\"" + url + "\">" + innerHtml + "</a>";
				text = text.replace(outerHtml, link)
			}
		}
		return text
	}
};
SpinToWin.prototype.randomInt = function (min, max) {
	return Math.floor(Math.random() * (max - min) + min)
};
SpinToWin.prototype.isNullOrWhitespace = function (input) {
	if (typeof input === "undefined" || input == null) return true;
	return input.replace(/\s/g, "").length < 1
};
SpinToWin.prototype.validateEmail = function (email) {
	var re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
	return re.test(email)
};
SpinToWin.prototype.setCloseButton = function () {
	if (this.config.closeButtonColor == "black") {
		this.closeButton.src = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAABvUlEQVRoQ+2Z4U0DMQyFfYsxRIEN2AomQEjMgBisKG0jRac0sf2ec1ZF//Qkkvh9fo4vDZtcP08i8nN7Ll9b85zx8dyIKtp/i+BXEfnsqM0K00JU2S9FbO8PdUA2mLtaZyCZymyU8MteGA64WXO0M1ONVeB04IENQKWtzbRqwuIWpta0Lxn1xAVAJi292jctEARk1nBvE5sXIgK5Yo+6kWtBEMgdc9ZW3Qs7gKBYM5CiBwqgBIJjaECiYWAI6/GDEnDnEG1NrSM1Pi0wu2StIKwyYybkkmQPCApDh0BAvDAhECiIFSYMggGihdG8TrxlDu2RvTBNtkcwEATLEUtr7sHAEGwQT5lRICJALDA0iH+Qwa61bnqaK7SFlGen9Jvd6sQeCE4ovADgBBUGBdE4seQSEAGxQFhemi5NrknKclp61eQB8TjhOZuZtJkGg06EwlhAGE6EwWhBIiCoDUADEglBg5mBrICgwDz8JfZKJygN4GH/0XOkE5AzrSOZIMwNYMnJVHOpBf7q3ApIRifMZaYBmb1rwISrpw8TPgPJAjHdM0Xou4i8dfKSDWIE81HFfonIcwOTFaIH8y0ipz/jH10bOlDCXQAAAABJRU5ErkJggg=="
	} else {
		this.closeButton.src = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAABwklEQVRoQ+2aa24CMQyE7QuUM7YHK2csF0i1qJF2A0lszxiiVfkDEnnM52fCoiIipZRvEfncPm8vVdX6ecX3UkrZ6bqq6pe2EKvDNBBV7nUD2dMdHLCaZ4ZaR1+uFGZTnbMBK8CYNP4leze83p0zJoh9DlgnvLKKeTQdyqxnYjaQV8tDv/AukAEU0fC08UUWYgFF9+528OiCCBCy5/AogizsBUL3mp6p0A0sQIw9piDZfYYBcW/aFotlwbAgXCBsGCaEG4QFw4YIgaAwGRBhkChMFgQE4oXJhIBBrDCWyojeRs3ldyTGYu3RfBSC4pEqMArDgKCCRMKMBUEH8cAwIf5BeonrzROmVyhVyxNSrRFYMBQQrycyYGAQFKJCoZ6BQCwQVaBnrOUk8ODVyCRrTrRWzoQJeQQRhMwdHnO8HmEIYawBhRZTAHMtV2dnbxzNs14EmXIkA8JzaraU5ilIJgQT5vw/mb7CE228I3ue97ECYhVvT0KuA20BON+jtxU8geTM3SMrQnhL8/AvHKy7Apo7JkPPBlm6KirUMn+qczRgFQhLmG2h9SMiHxn3aIulvWM6hr/VZD/ArOaJSTW7qerlF9bSa7Pl7TDpAAAAAElFTkSuQmCC"
	}
};

var Sound = (function () {
	var df = document.createDocumentFragment();
	return function Sound(src) {
		var snd = new Audio(src);
		snd.currentTime = 0;
		snd.setAttribute("playsinline", true);
		snd.setAttribute("autoplay", true);
		snd.setAttribute("preload", "auto");
		df.appendChild(snd); // keep in fragment until finished playing
		return snd;
	}
}());

var snd = null;

SpinToWin.prototype.playTick = function () {
	if (!snd && window.spinToWin.easyWheelInitialized) {
		snd = Sound("data:audio/wav;base64,UklGRlQbAABXQVZFZm10IBAAAAABAAEAgLsAAAB3AQACABAATElTVCgAAABJTkZPSUdOUgYAAABCbHVlcwBJU0ZUDgAAAExhdmY1OC43Ni4xMDAAZGF0YQAbAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAA/////wAAAAAAAAEAAQAAAAAAAAAAAAAAAAAAAAAA////////AAD/////AQACAAEAAAAAAAAA/////wAAAQAAAAAAAgACAAEA////////AAD/////AAAAAAAAAQD///7//v8BAAMAAgAAAP/////9//7/AgAEAAQAAQD//wAA///8//v//v///wAABwAKAAMA/P/9/////v/9//3//v////7///8CAAEA/v8DAAsACAABAAEA///3//f//P///wIABQADAAcACgAAAPf/+v/9//z/AgAKAAgA/f/1//r/BQAKAAQA+//1//j//v/7//n/BAAOAAgA//8BAAcACAACAPz///8HAAUA+P/2/wMACgAGAAAA9f/w//n/+//5/wMABQD4//7/DgAHAAUADwAAAO3/+v8KAAQA+//3////DgAJAPv/AAADAPb/9f/+//r/+P8JABcADQD1//D/AAAJAAkAEgAMAO3/5f8AAAcA8f/y/wsADAABAA0AFwD+/+v/9f///wMAAwD5//r/CgADAPT//f8HAAYACAD+//f/FAAoAAoA5v/b/+z/EAAZAAEA/P8BAO//8P8EAPv/9P8OABcABwAEAPr/4f/m/w0AIAAFAOr/+f8WABMABAADAAAA+P///xEADwD1/+P/8f8FAAQA+f/1/wEAGQAaAPz/6f/z/wwAHwAJANj/y//l////IgAzAAoA6/8FABIA//8AAAQA8//t//v/CwASAAUA+P8DAAwA+v/r//X/BgAMAP//9v8LABgA9v/T/+f/EgAbAA4ABgD3/+D/5f8CABQAJQAzABQA5f/o//n/3P/P/w4AQgAYAOT/8v/7/9X/4P8oAD4AIAAVAPz/v/+2//j/LQAvACAAFQALAAEA9P/o/+P/4v/j/+v/9/8LADMATQAdAM7/wP/c/+T/BQBEADsA+f/y/wcA3v/F/xAAVAAqAOn/8P/5/8//wf/y/xsAJQAtAB0A8f/g/+r/7v8DADEANgD3/8r/6/8VAAYA8P8AABcAFgD8/+L/6f////7/+P8IABoAGAABAOr/8P/6/+z/+P8UAPH/yP/8/0IASwA3AAkAxf+6//H/HwAeAPf/1P/l/xQAIQAJAPP//P8eACYA9//N/93/BgAPAPn/8v/7/+//7v8WACUA8v/R/wQARgA6APT/2P/p/+v//P8kABYA+f8XABsA6P/f/+7/4f/9/z0APgAAALn/o//o/zAAHwD6//r/+v8LACAABQDy/wwADADy//b/AwAQABYA7f/E/+n/FAABAP3/JwAoAPj//v8uABMAxP/A/+7//P8RADQAFADO/8P/+v8rACcADQASABMA8//z/wQA6f/i/xAAHQABAO//7f8PACYA5/++//X/BQDr/xcANAABAP//LwAuAB4AGQD7/9j/z//d/woAJgD7/8j/0v/5/wYA8f/i//r/GgARAPD/7P8VAD4AMAAQABsAKgAFAMf/rf/d/zQASAAAALr/vf/2/yYAJAAVAA0A5v/N//3/GgD+/woAMAAoABoACADV/8T/0/+//8z/GAAoAPT/8v8WABoAGgAzAEIAKAADAAYAGgD4/7P/pP/h/yAAIgAHAAYAAgDj/+X/BwDx/7v/3P9CAGcALADw/+f/9f/5//f/+v8IAA4AAAABABsACgDS/9X/DgAYAPL/4P/s/wMAHAAnABoAAQD1/wgAKwAuAPz/w//A/+L/7v/y/wQAAwADADEAQQD//9v/CwAlAPr/1//r/wUA8f/P/9b//P8kAD4AJgDr/+r/JAAzAPv/2v8CACkAFwD7/+//3P/f//n/4f/Q/xoASgAOAN3/8f8EAPT/3P/x/ywAJgD8/x0ANgD6/+n/CQD2/+7/CgABAPz/BQDX/83/IgA9APH/wP/i/yMALgABAP3/CgDa/9z/KgAQALr/5P8yACAAAwALAPv/7v8TACYA+P/t/ycAFgDH/+T/MgAgAPr/0P+P/93/dQA9AMT/CwBSAPr/q//R/x0AEQDA//b/dwA1ANL/MABJAMv/tP/N/7r/7v8EAMT/BQBsAC0A/v9HAE8ACgDo/+v/+f/n/9L/BwAbAMP/p//u/xMAGgAkABIAGgBFADMA2/+n//f/dQA+AHL/RP/y/30AKwCW/xkAEQFZAA7/5//5AIX/RP7T/10BSgDe/s7/WgFsAOb+HgBaAYP/bv59AIEBCgB2/zgATwCk/wf/HP8eAL0A/f9d/0QARQGGAET/tv+nADAAzP9FAMP/B//x/2gAXv/Q/zoB7P8V/gsAjgLpAJX+n/+zAI3/WP8kAKL//f+bAWAA//1o/1IBef8D/gsA+wH5AXYBAADN/Qz+dwBaADD+av9yAjwBfv7j/+YBOQBO/gj/4gAAAl8AY/0D//kDKwMv/bj7Sf/QAM3/if/e/+8AjAJ9ALv7Xf2GBI4Eb/0d/P4AEwLl/zYAXgFvAXABIP8P+1j8fgJcAyj+9fwdAX4CGQAI/4D/xf9IAD8A+v+vAbUC6P/o/dn/3QCq/lf8C/zj/1oGJQYw/j78BgNXA3L7+vrpAdcBMP2I/6UDmwGn/9v/jPzl+18DtAWP/V37fQLbAuD8sv6JBNACy/3j/Ej+0ADyAnr/Jvtr/14ELf+V+qsAYAZfBKkBQP/q+wP+RAG8+4v5VgVfCcb6g/YEBiMJXPqi+cwHxwch+rX1qwMnIyk8wRq7wxqbIdujMB431gBy3SLsChIyIjkJJOwz91YR3QgC9CQISTFrLeLyC7uBvcL5KjQUNAQLi/ZNBesTzA5i/fzp8+PZ80AFcwakB8gSHBMtAWvunuGS4csCVzKhMan4r81+2woDXR01H+gKO/dk/80RHgiJ7lnsRvt7/SL5tQHcDn4SXw67Al7vpuTh8EwI1BVQEmECMfE07V358wZcCDsBzP03AS4CQvpX8/H5dAbNBzcA7v8/CTUQmA35AYTyc+vq9DEExwkvBzUFgAIu/ST8ngB9ATT+4wBfCIsHCP4i+kYA/AXcBDEADfzm/NIFKQ2mBHXzOPCe/ZkI+wg/BysHJgYcBXYCU/rn9Pn91wwzDvwBn/id+kMDMwmcBKj4r/Tg/48MTguc/0v4T/zMBLAG9QAN/qkDbAlxBgn+J/nM+9kCgQZfAuX8Q/6lAsIBtf0Y/fH+g/+F/y0A/QBYAisDngDk/LP9twHeAWv99for/n8DCAUoAQ/9qP6lAxgEWP6B+XT7oQGlBAsBFvx4/QMEcwYDAb364voDAKEDHgLp/W38cf/XApgC6/89/pH+x/+RAGcA9f8IAEkAdAC9AA8A0v30/MH/2gJIAtP/Bv/8/z4BVgG7/oP76/xxAt8EsgFR/ln+EwCUAa4BRv+m/Kr96QDPAUwAcP/H/3cAPgHfAPH+Qf5SABYCHgEX/yz+5f7qAB0CYAD+/bv+JQFuAQkASP8j/3//xgAUAS//IP70/80BmQHtACgAeP7p/fD/dQFOAA7/i/9PAKgA3AD5/3/+/P4CAUwBxf8j/8z/agC/AIMAYP/Y/u7/wQAhALv/RABjAA0ABwCZ/67++/5rAOsAYQAtAB0A6v+IAFABPgA1/vz9iP+2APQAsgD+/5T/MQC1APX/Cf85/+r/SQB1AGoADgDj/xEA+/+V/4D/0P83AKAArAD7/03/lP9MAFgAw/9S/3L/NAAYAR0BGgBR/4v/AQDq/5//pP/g/ysAdgCFADkA7v/u/wIA6f+8/67/xf8AAEsAXwAYANn//f9AACoAyv+Y/8P/FwBCACAA3P/O/wsAQgA4AAUA2//S/+n/AwAEAPz/CQAcABsADQD4/9//2//5/xAACQABAAsADwD//+z/5P/0/xkAMQAbAPL/5P/t/+//7f/0/wIAEQAgACIACwDt/+L/6//3//3/AQAFAAwAEgAJAPL/6P/6/xAADQD3/+z/8/8BAAkABgD+/wAACwANAP//7f/o//H/AwAPAA4ABwAFAAUA/f/u/+n/9P8GABEADQACAP3/AAAAAPr/9f/6/wgADwAHAPX/7f/1/wQADQAMAAcABQAEAP3/8v/r//P/BQATABMACAD9//r/+v/5//b/+P8BAA0ADwAFAPj/9v/+/wUABgACAAEAAwADAPv/8//y//3/CQAOAAsABQAAAPz/+f/3//f//P8FAAwACgACAPz/+//+/wAA///+/wAAAwAEAAAA/P/8////AgADAAIAAgABAAEA///9//z//f8AAAMABAADAAEAAAD//////v/+////AQACAAIAAAD/////AAABAAAAAAAAAAEAAQAAAP7//v///wEAAgABAAEAAAAAAP//////////AQACAAEAAAAAAAAAAAAAAAAAAAAAAAEAAAAAAP//AAAAAAAAAAAAAAAAAAAAAAAA/////wAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=");
	}
	if (snd) {
		snd.play();
	}
};
