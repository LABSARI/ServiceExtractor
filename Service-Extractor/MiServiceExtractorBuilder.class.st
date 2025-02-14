Class {
	#name : 'MiServiceExtractorBuilder',
	#superclass : 'HSimpleVisualizationBuilder',
	#instVars : [
		'highlightShapes'
	],
	#category : 'Service-Extractor-Browser',
	#package : 'Service-Extractor',
	#tag : 'Browser'
}

{ #category : 'building' }
MiServiceExtractorBuilder >> build [

	self buildServices.
	super build
]

{ #category : 'building' }
MiServiceExtractorBuilder >> buildClassNodeFromAssoc: assoc from: anExtraction [

	| node methods |
	methods := (assoc value select: #isMethod) reject: [ :m |
		           m name = '<Initializer>' ].
	node := HNode new
		        rawModel: assoc key;
		        name: assoc key name;
		        expand;
		        addAll: (methods collect: [ :m |
					         self buildNodeFromMethod: m from: anExtraction ]);
		        yourself.
	^ node
]

{ #category : 'building' }
MiServiceExtractorBuilder >> buildNodeFromExtraction: anExtraction [

	| node dict |
	node := HNode new
		        rawModel: anExtraction;
		        name:
			        'Extraction '
			        , (mapModel extractions indexOf: anExtraction) asString;
		        expand;
		        addAll: (anExtraction classes associations collect: [ :a |
					         self buildClassNodeFromAssoc: a from: anExtraction ]);
		        style: (HBorderAndTitleStyle new
				         borderWidth: 2;
				         borderDashArray: #( 4 );
				         yourself);
		        color: Color transparent;
		        yourself.
	dict := Dictionary new.
	(node allChildren select: [ :c | c rawModel isMethod ]) do: [ :hn |
		dict at: hn rawModel put: hn ].

	dict keysDo: [ :m |
		mapModel uccg callGraph at: m ifPresent: [ :c |
			c do: [ :mm |
				dict at: mm ifPresent: [ :hn | (dict at: m) dependencyTo: hn ] ] ] ].



	^ node
]

{ #category : 'building' }
MiServiceExtractorBuilder >> buildNodeFromMethod: method from: anExtraction [

	| node |
	node := HNode new
		        rawModel: method;
		        name: method name , ': ', (uccg entryPointsUsing: method) size asString;
		        color: (self colorForMethod: method in: anExtraction);
		        yourself.

	^ node
]

{ #category : 'building' }
MiServiceExtractorBuilder >> buildServices [

	| nodes |
	rootNode := HNode new.

	nodes := self mapModel extractions collect: [ :e |
		self buildNodeFromExtraction: e
	].
	rootNode addAll: nodes.
]

{ #category : 'building' }
MiServiceExtractorBuilder >> colorForMethod: method in: anExtraction [

	| domMethods |
	domMethods := anExtraction methodsToExtract flatCollectAsSet: [ :m |
		              uccg dominatedMethodsFrom: m ].

	(anExtraction methodsToExtract includes: method) ifTrue: [
		^ Color fromHexString: '4FA7E2' ].

	(domMethods includes: method) ifTrue: [
		^ Color fromHexString: '058B71' ].

	^ Color gray
]

{ #category : 'building' }
MiServiceExtractorBuilder >> highlightable [

	^ highlightable ifNil: [ 
		  highlightable := RSHighlightable new
			                   highlightShapes: [ :shape | 
				                   | list |
				                   list := shape connectedLines copy.
				                   list add: (shape propertyAt: #background).
				                   list ];
			                   when: RSHighlightEvent do: [ :evt | 
				                   evt shape isNode
					                   ifTrue: [ 
						                   highlightable
							                   record: evt shape
							                   selector: #border
							                   value: (RSBorder new
									                    color: (Color fromHexString: 'FF7F00');
									                    width: 3;
									                    yourself) ]
					                   ifFalse: [ 
					                   highlightable
						                   record: evt shape
						                   selector: #color
						                   value: Color red ] ]
			                   for: self;
			                   when: RSUnHighlightEvent do: [ :evt | 
				                   evt shape isNode
					                   ifTrue: [ 
					                   highlightable
						                   restore: evt shape
						                   selector: #border ]
					                   ifFalse: [ 
					                   highlightable
						                   restore: evt shape
						                   selector: #color ] ]
			                   for: self;
			                   yourself ]
]

{ #category : 'building' }
MiServiceExtractorBuilder >> highlightableLinkedShapes [

	^ highlightShapes ifNil: [ 
		  highlightShapes := RSHighlightable new
			                     highlightShapes: [ :shape | 
				                     | list |
				                     list := Set new.
				                     shape connectedLines do: [ :line | 
						                     shape = line from
							                     ifTrue: [ 
								                     list add:
										                     (line to propertyAt: #background) ]
							                     ifFalse: [ 
								                     list add:
										                     (line from propertyAt: #background) ] ].
				                     list asOrderedCollection ];
			                     when: RSHighlightEvent do: [ :evt | 
				                     | color |
				                     color := Color fromHexString: 'F1C40F'.
				                     highlightable
					                     record: evt shape
					                     selector: #color
					                     value: color ]
			                     for: self;
			                     when: RSUnHighlightEvent
			                     do: [ :evt | 
				                     highlightable
					                     restore: evt shape
					                     selector: #color ]
			                     for: self;
			                     yourself ]
]

{ #category : 'building' }
MiServiceExtractorBuilder >> nodeAnnouncer [
	"plug new events here"

	baseNode ifNotNil: [ ^ baseNode announcer ].
	baseNode := RSComposite new
		            @ self popup;
		            @
			            (HGhostDraggable new color:
					             Smalltalk ui theme caretColor);
		            @ self menuInteraction;
		            @ self highlightable;
		            @ RSNodeOnTopWhenPositionChanged new;
		            @ HUpdateSelectionBox new;
		            @ self highlightableLinkedShapes;
		            @ HResizeParentWhenChildMoves new;
		            yourself.
	^ baseNode announcer
]

{ #category : 'rendering' }
MiServiceExtractorBuilder >> renderIn: aCanvas [

	| dup |
	super renderIn: aCanvas.
	dup := (aCanvas canvas allChildren
		        select: [ :s |
			        s model notNil and: [
				        s model class = HNode and: [
					        s model rawModel isMooseObject and: [
						        s model rawModel isMethod ] ] ] ]
		        thenCollect: [ :e | e model rawModel ]) groupedBy: [ :a | a ].

	(aCanvas allChildren select: [ :s |
		 s model notNil and: [
			 s model class = HNode and: [
				 s model rawModel isMooseObject and: [ s model rawModel isMethod ] ] ] ])
		do: [ :s | "s
				when: RSMouseLeftClick
				do: [ :e |
					MiInspectorBrowser inspect:
						(uccg entryPointsUsing: e shape model) ]
				for: self."
			(dup at: s model rawModel) size > 1 ifTrue: [
				(s propertyAt: #background) color: Color red.
				(s parent parent propertyAt: #background) color: Color red ] ].
	aCanvas lines do: #update.
	aCanvas signalUpdate.
	aCanvas zoomToFit
]
