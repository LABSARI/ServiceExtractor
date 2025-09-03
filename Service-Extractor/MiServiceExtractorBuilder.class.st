Class {
	#name : 'MiServiceExtractorBuilder',
	#superclass : 'HSimpleVisualizationBuilder',
	#instVars : [
		'highlightShapes',
		'layerColor',
		'domMethods',
		'monolithNode',
		'solution',
		'validateButton'
	],
	#category : 'Service-Extractor-Browser',
	#package : 'Service-Extractor',
	#tag : 'Browser'
}

{ #category : 'building' }
MiServiceExtractorBuilder >> addMonolithChildrenFromSolution [

	| solutions |
	solutions := self mapModel extractions collect: [ :assoc |
		             assoc value ].
	solutions ifEmpty: [ ^ self ].
	((solutions flatCollectAsSet: [ :s | s methodsInMonolith ])
		 groupedBy: #parentType) associationsDo: [ :assoc |
		monolithNode add: (HNode new
				 rawModel: assoc key;
				 name: assoc key name , ' ' , assoc value size asString , '/'
					 , assoc key methods size asString;
				 expand;
				 addAll:
					 (assoc value collect: [ :m | self buildNodeFromMethod: m ]);
				 yourself) ]
]

{ #category : 'building' }
MiServiceExtractorBuilder >> build [

	rootNode := HNode new.
	rootNode layout: (RSHorizontalLineLayout new horizontalGap: 200).
	self buildMonolith.
	self buildServices.
	self buildMenu.
	
	super build
]

{ #category : 'building' }
MiServiceExtractorBuilder >> buildClassNodeFromAssoc: assoc from: anExtraction [

	| node methods |
	methods := (assoc value select: #isMethod) reject: [ :m |
		           m name = '<Initializer>' or: [
			           solution methodsInMonolith includes: m ] ].
	node := HNode new
		        rawModel: assoc key;
		        name: assoc key name , ' ' , methods size asString , '/'
			        , assoc key methods size asString;
		        expand;
		        addAll: (methods collect: [ :m |
					         self buildNodeFromMethod: m from: anExtraction ]);
		        yourself.
	^ node
]

{ #category : 'building' }
MiServiceExtractorBuilder >> buildClassNodeFromAssoc: assoc from: anExtraction solution: aSolution [

	| node methods |
	methods := (assoc value select: #isMethod) reject: [ :m |
		           m name = '<Initializer>' or: [
			           aSolution methodsInMonolith includes: m ] ].
	node := HNode new
		        rawModel: assoc key;
		        name: assoc key name , ' ' , methods size asString , '/'
			        , assoc key methods size asString;
		        expand;
		        addAll: (methods collect: [ :m |
					         self buildNodeFromMethod: m from: anExtraction solution: aSolution]);
		        yourself.
	^ node
]

{ #category : 'building' }
MiServiceExtractorBuilder >> buildMenu [

	validateButton := RSComposite new.
	validateButton
		add: (RSLabel new
				 fontSize: 13;
				 text: 'SAVE INCREMENT';
				 color: Color black;
				 yourself);
		border: (RSBorder new
				 color: (Color fromHexString: '88888899');
				 yourself);
		color: (Color fromHexString: 'AAAAAA33').
	validateButton @ (RSHighlightable new
		 highlightColor: (Color fromHexString: 'AAAAAA99');
		 yourself).
	validateButton
		adjustToChildren;
		padding: 5.
	validateButton translateBy:
		validateButton width / 2 + 10 @ (validateButton height / 2 + 10).
	self container add: validateButton.

	validateButton setAsFixed.

	validateButton when: RSMouseClick do: [ self saveIncrement ] for: self
]

{ #category : 'building' }
MiServiceExtractorBuilder >> buildMonolith [

	monolithNode := HNode new
		                name: 'Monolith';
		                expand;
		                style: (HBorderAndTitleStyle new
				                 borderWidth: 2;
				                 borderDashArray: #( 1 );
				                 yourself);
		                color: ((Color fromHexString: 'DEDEDE') alpha: 0.2);
		                yourself.
	self addMonolithChildrenFromSolution.
	rootNode add: monolithNode
]

{ #category : 'building' }
MiServiceExtractorBuilder >> buildNodeFromExtraction: anExtraction [

	| node dict |
	self setDominatedMethodsFrom: anExtraction.
	node := HNode new
		        rawModel: anExtraction;
		        name:
			        'Extraction '
			        , (mapModel extractions indexOf: anExtraction) asString
			        , String cr , 'Number of classes: '
			        , anExtraction classes keys size asString , String cr
			        , 'Number of methods: '
			        ,
				        (anExtraction classes values flatten collect: #isMethod)
					        size asString;
		        expand;
		        addAll: (self createLayersFrom: anExtraction);
		        style: (HBorderAndTitleStyle new
				         borderWidth: 2;
				         borderDashArray: #( 1 );
				         yourself);
		        color: ((Color fromHexString: 'DEDEDE') alpha: 0.2);
		        layout: (RSHorizontalLineLayout new
				         alignMiddle;
				         horizontalGap: 100);
		        yourself.
	dict := Dictionary new.
	(node allChildren , monolithNode allChildren select: [ :c |
		 c rawModel isMooseObject and: [ c rawModel isMethod ] ]) do: [ :hn |
		dict at: hn rawModel put: hn ].

	dict keysDo: [ :m |
		mapModel uccg callGraph at: m ifPresent: [ :c |
			c do: [ :mm |
				dict at: mm ifPresent: [ :hn | (dict at: m) dependencyTo: hn ] ] ] ].

	^ node
]

{ #category : 'building' }
MiServiceExtractorBuilder >> buildNodeFromExtraction: anExtraction solution: aSolution [

	| node dict |
	self setDominatedMethodsFrom: anExtraction.
	node := HNode new
		        rawModel: anExtraction;
		        name:
			        'Extraction '
			        , (mapModel extractions indexOf: anExtraction) asString
			        , String cr , 'Number of classes: '
			        , anExtraction classes keys size asString , String cr
			        , 'Number of methods: '
			        ,
				        (anExtraction classes values flatten collect: #isMethod)
					        size asString;
		        expand;
		        addAll: (self createLayersFrom: anExtraction solution: aSolution);
		        style: (HBorderAndTitleStyle new
				         borderWidth: 2;
				         borderDashArray: #( 1 );
				         yourself);
		        color: ((Color fromHexString: 'DEDEDE') alpha: 0.2);
		        layout: (RSHorizontalLineLayout new
				         alignMiddle;
				         horizontalGap: 100);
		        yourself.
	dict := Dictionary new.
	(node allChildren , monolithNode allChildren select: [ :c |
		 c rawModel isMooseObject and: [ c rawModel isMethod ] ]) do: [ :hn |
		dict at: hn rawModel put: hn ].

	dict keysDo: [ :m |
		mapModel uccg callGraph at: m ifPresent: [ :c |
			c do: [ :mm |
				dict at: mm ifPresent: [ :hn | (dict at: m) dependencyTo: hn ] ] ] ].

	^ node
]

{ #category : 'building' }
MiServiceExtractorBuilder >> buildNodeFromMethod: method [

	| node |
	node := HNode new
		        rawModel: method;
		        name:
			        method name , ': '
			        , (uccg entryPointsUsing: method) size asString;
		        yourself.

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
MiServiceExtractorBuilder >> buildNodeFromMethod: method from: anExtraction solution: aSolution [

	| node |
	node := HNode new
		        rawModel: method;
		        name:
			        method name , ': '
			        , (uccg entryPointsUsing: method) size asString;
		        color:
			        (self
				         colorForMethod: method
				         in: anExtraction
				         solution: aSolution);
		        yourself.

	^ node
]

{ #category : 'building' }
MiServiceExtractorBuilder >> buildServices [

	| nodes |
	nodes := self mapModel extractions collect: [ :assoc  |
		self buildNodeFromExtraction: assoc key solution: assoc value
	].
	rootNode addAll: nodes.
]

{ #category : 'building' }
MiServiceExtractorBuilder >> colorForLayer: aSymbol [

	^ layerColor at: aSymbol 
]

{ #category : 'building' }
MiServiceExtractorBuilder >> colorForMethod: method in: anExtraction [

	(anExtraction methodsToExtract includes: method) ifTrue: [
		^ Color fromHexString: '4FA7E2' ].

	(domMethods includes: method) ifTrue: [
		^ Color fromHexString: '058B71' ].

	(solution methodsDuplicated includes: method) ifTrue: [
		^ Color orange ].
	^ Color gray
]

{ #category : 'building' }
MiServiceExtractorBuilder >> colorForMethod: method in: anExtraction solution: aSolution [

	(anExtraction methodsToExtract includes: method) ifTrue: [
		^ Color fromHexString: '4FA7E2' ].

	(domMethods includes: method) ifTrue: [
		^ Color fromHexString: '058B71' ].

	(aSolution methodsDuplicated includes: method) ifTrue: [
		^ Color orange ].
	^ Color gray
]

{ #category : 'building' }
MiServiceExtractorBuilder >> createLayersFrom: anExtraction [

	| classNodes groups groupNodes |
	classNodes := (anExtraction classes associations reject: [ :a |
		               a key isInterface ]) collect: [ :a |
		              self buildClassNodeFromAssoc: a from: anExtraction ].
	classNodes := classNodes reject: [ :cn | cn children isEmpty ].
	groups := classNodes groupedBy: [ :cn | self layerOf: cn ].
	groupNodes := groups associations collect: [ :assoc |
		              | layer nodes layerNode |
		              layer := assoc key.
		              nodes := assoc value.
		              layerNode := HNode new
			                           rawModel: layer;
			                           name: layer asString;
			                           color: (self colorForLayer: layer);
			                           expand;
			                           addAll: nodes;
			                           style: (HBorderAndTitleStyle new
					                            borderWidth: 2;
					                            borderDashArray: #( 4 );
					                            yourself);
			                           yourself ].
	^ {
		  (groupNodes detect: [ :gn | gn rawModel = #transverse ]).
		  (HNode new
			   rawModel: #layers;
			   expand;
			   addAll:
				   ((groupNodes reject: [ :gn | gn rawModel = #transverse ])
					    sort: [ :a :b | a rawModel > b rawModel ]);
			   style: (HBorderAndTitleStyle new
					    borderWidth: 0;
					    borderDashArray: #( 4 );
					    yourself);
			   layout: (RSVerticalLineLayout new alignCenter; verticalGap: 150);
			   color: Color transparent;
			   yourself) }
]

{ #category : 'building' }
MiServiceExtractorBuilder >> createLayersFrom: anExtraction solution: aSolution [

	| classNodes groups groupNodes |
	classNodes := (anExtraction classes associations reject: [ :a |
		               a key isInterface ]) collect: [ :a |
		              self buildClassNodeFromAssoc: a from: anExtraction solution: aSolution ].
	classNodes := classNodes reject: [ :cn | cn children isEmpty ].
	groups := classNodes groupedBy: [ :cn | self layerOf: cn ].
	groupNodes := groups associations collect: [ :assoc |
		              | layer nodes layerNode |
		              layer := assoc key.
		              nodes := assoc value.
		              layerNode := HNode new
			                           rawModel: layer;
			                           name: layer asString;
			                           color: (self colorForLayer: layer);
			                           expand;
			                           addAll: nodes;
			                           style: (HBorderAndTitleStyle new
					                            borderWidth: 2;
					                            borderDashArray: #( 4 );
					                            yourself);
			                           yourself ].
	^ {
		  (groupNodes detect: [ :gn | gn rawModel = #transverse ]).
		  (HNode new
			   rawModel: #layers;
			   expand;
			   addAll:
				   ((groupNodes reject: [ :gn | gn rawModel = #transverse ])
					    sort: [ :a :b | a rawModel > b rawModel ]);
			   style: (HBorderAndTitleStyle new
					    borderWidth: 0;
					    borderDashArray: #( 4 );
					    yourself);
			   layout: (RSVerticalLineLayout new alignCenter; verticalGap: 150);
			   color: Color transparent;
			   yourself) }
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
MiServiceExtractorBuilder >> initialize [

	super initialize.
	layerColor := {
		              (#transverse
		               -> ((Color fromHexString: '9B59B6') alpha: 0.2)).
		              (#logic
		               -> ((Color fromHexString: 'E67E22') alpha: 0.2)).
		              (#data -> ((Color fromHexString: 'C0392B') alpha: 0.3)).
		              (#presentation
		               -> ((Color fromHexString: '16A085') alpha: 0.2)) }
		              asDictionary
]

{ #category : 'building' }
MiServiceExtractorBuilder >> layerOf: anHNode [

	((anHNode rawModel name beginsWith: 'Uc') or: [
		 anHNode rawModel name beginsWith: 'IUc' ]) ifTrue: [
		^ #presentation ].
	((anHNode rawModel name beginsWith: 'Service') or: [
		 anHNode rawModel name beginsWith: 'IService' ]) ifTrue: [ ^ #logic ].
	((anHNode rawModel name beginsWith: 'Dao') or: [
		 anHNode rawModel name beginsWith: 'IDao' ]) ifTrue: [ ^ #data ].
	^ #transverse
]

{ #category : 'accessing - attributes' }
MiServiceExtractorBuilder >> menuItemStrategy [

	^ MiServiceExtractorMenuItemStrategy new
]

{ #category : 'computing' }
MiServiceExtractorBuilder >> moveClassToMonolith: anHNode [

	anHNode moveTo: monolithNode.
	self container lines do: [ :l |
		l from model nodeParent ~= l to model nodeParent ifTrue: [
			l color: Color red ] ]
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
	"dup := (aCanvas canvas allChildren
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
		do: [ :s | ""s
				when: RSMouseLeftClick
				do: [ :e |
					MiInspectorBrowser inspect:
						(uccg entryPointsUsing: e shape model) ]
				for: self.""
			(dup at: s model rawModel) size > 1 ifTrue: [
				(s propertyAt: #background) color: Color red.
				(s parent parent propertyAt: #background) color: Color red ] ]."
	aCanvas lines do: #update.
	aCanvas signalUpdate.
	aCanvas zoomToFit
]

{ #category : 'building' }
MiServiceExtractorBuilder >> saveIncrement [
	1halt.
	(Smalltalk at: #allExtractions ifAbsentPut: [ OrderedCollection new ])
		add: self mapModel extractions last -> solution.
	
]

{ #category : 'building' }
MiServiceExtractorBuilder >> setDominatedMethodsFrom: anExtraction [

	domMethods := uccg dominatedMethodsFromMethods:
		              anExtraction methodsToExtract
]
