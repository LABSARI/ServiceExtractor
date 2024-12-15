Class {
	#name : 'MiServiceExtractorBrowser',
	#superclass : 'MiAbstractBrowser',
	#instVars : [
		'methodList',
		'functionalityMethods',
		'canvas',
		'submitButton'
	],
	#category : 'Service-Extractor',
	#package : 'Service-Extractor'
}

{ #category : 'instance creation' }
MiServiceExtractorBrowser class >> newModel [

	^ MiServiceExtractorModel new
]

{ #category : 'instance creation' }
MiServiceExtractorBrowser class >> open [

	<script>
	^ super open
]

{ #category : 'specs' }
MiServiceExtractorBrowser class >> title [

	^ 'Service Extractor'
]

{ #category : 'specs' }
MiServiceExtractorBrowser class >> windowSize [

	^ self currentWorld extent
]

{ #category : 'actions' }
MiServiceExtractorBrowser >> buildDominatorTreeVisualization [

	| getColor s |
	getColor := [ :m |
	            | c |
	            c := Color purple.
	            (m parentType name
		             includesSubstring: 'uc'
		             caseSensitive: false) ifTrue: [ c := Color green ].
	            (m parentType name
		             includesSubstring: 'dao'
		             caseSensitive: false) ifTrue: [ c := Color blue ].
	            (m parentType name
		             includesSubstring: 'service'
		             caseSensitive: false) ifTrue: [ c := Color red ].

	            c ].

	s := specModel uccg dominatorTree keys collect: [ :m |
		     | shape |
		     shape := RSCircle new
			              size: 2;
			              model: m;
			              color: (getColor value: m);
			              yourself.
		     shape @ (RSPopup new
			      text: [ :model | model name ];
			      yourself).
		     shape ].

	RSLineBuilder line
		color: Color gray translucent;
		withBorderAttachPoint;
		canvas: canvas canvas;
		shapes: s;
		connectFrom: [ :m | specModel uccg dominatorTree at: m ].
	RSTreeLayout on: s.
	canvas canvas addAll: s.
	canvas canvas signalUpdate.
	canvas canvas @ RSCanvasController
]

{ #category : 'actions' }
MiServiceExtractorBrowser >> buildExtractionMap [

	| methodsToExtract extractions extractionShapes sets dup lb |
	self assert: methodList selectedItems size = 2.
	methodsToExtract := methodList selectedItems first: 2.
	extractions := methodsToExtract collect: [ :m |
		               ServiceExtractor new
			               extractMethods: { m };
			               yourself ].

	extractionShapes := extractions
		                    collect: [ :e | self shapeForExtraction: e ]
		                    as: RSGroup.
	(RSHorizontalLineLayout withGap: 40) on: extractionShapes.
	sets := extractionShapes collect: [ :e |
		        (e allChildren
			         select: [ :s |
			         s model isMooseObject and: [ s model isMethod ] ]
			         thenCollect: #model) asSet ].
	dup := Set intersectSets: sets.



	lb := RSLabel text:
		      'Number of duplicated methods: ' , dup size asString.
	RSVerticalLineLayout new alignLeft on: {
			lb.
			extractionShapes }.
	canvas canvas add: lb.
	canvas canvas addAll: extractionShapes.
	(canvas canvas allChildren select: [ :s |
		 s model isMooseObject and: [ s model isMethod ] ]) do: [ :s |
		(dup includes: s model) ifTrue: [
			s color: Color red ] ].
	canvas canvas lines do: #update.
	canvas canvas signalUpdate
]

{ #category : 'actions' }
MiServiceExtractorBrowser >> buildMap [

	| methodToShow subgraph allMethods shapes comps |
	methodToShow := methodList selectedItems first.
	specModel uccg computeModules.
	subgraph := specModel uccg callGraphOf: methodToShow.
	allMethods := Set withAll: subgraph keys , subgraph values flatten.
	
	shapes := allMethods collect: [ :m |
		          | shape |
		          shape := RSCircle new
			                   size: 10;
			                   model: m;
			                   color: (self colorFor: m);
			                   yourself.
		          shape @ (RSPopup new
			           text: [ :model |
				           model name , (uccg predecessors: m) size asString ];
			           yourself).
		          shape ].

	comps := (shapes groupedBy: [ :s |
		          s model tags
			          ifEmpty: [ s model ]
			          ifNotEmpty: [ s model tags first ] ]) associations
		         collect: [ :assoc |
			         RSFlowLayout on: assoc value asOrderedCollection.
			         RSComposite new
				         shapes: assoc value;
				         padding: 20;
				         color: Color gray translucent translucent;
				         adjustToChildren;
				         yourself ].
	RSFlowLayout on: comps asOrderedCollection.

	canvas canvas addAll: comps.
	"RSLineBuilder arrowedLine
		withBorderAttachPoint;
		width: 1;
		canvas: canvas canvas;
		shapes: shapes asOrderedCollection;
		connectToAll: [ :m | specModel uccg callGraph at: m ifAbsent: [ {  } ] ]."
	canvas canvas signalUpdate
]

{ #category : 'testing' }
MiServiceExtractorBrowser >> canFollowEntity: anObject [

	^ anObject asMooseGroup allSatisfy: [ :m | m isMethod ]
]

{ #category : 'actions' }
MiServiceExtractorBrowser >> colorFor: method [

	(method isSetter or: [ method isGetter ]) ifTrue: [ ^ Color brown ].

	^ Color gray
]

{ #category : 'actions' }
MiServiceExtractorBrowser >> connectPresenters [

	submitButton action: [ 
		
		self run ]
]

{ #category : 'actions' }
MiServiceExtractorBrowser >> followEntity: anEntity [

	| list |
	list := anEntity asOrderedCollection.
	methodList items: list.
	specModel methodList: list.
	specModel buildCallGraph.
]

{ #category : 'actions' }
MiServiceExtractorBrowser >> initializePresenters [

	| sep |
	methodList := (self instantiate: SpFilteringSelectableListPresenter)
		              display: [ :i | i parentType name , '>>' , i name ].
	submitButton := self newButton label: 'Submit'.
	canvas := self newRoassal.
	canvas canvas @ RSCanvasController.

	sep := self newRoassal.

	sep canvas color: (Color fromHexString: 'BBBBBB').

	self layout: (SpBoxLayout newLeftToRight
			 add: (SpBoxLayout newTopToBottom
					  add: methodList;
					  add: submitButton expand: false;
					  yourself)
			 width: 300;
			 add: sep width: 1;
			 add: canvas;
			 yourself)
]

{ #category : 'actions' }
MiServiceExtractorBrowser >> miSelectedItem [

	^ {  }
]

{ #category : 'actions' }
MiServiceExtractorBrowser >> resetCanvas [

	canvas canvas shapes do: #remove
]

{ #category : 'actions' }
MiServiceExtractorBrowser >> run [

	methodList items ifEmpty: [ ^self ].
	self resetCanvas.
	self buildExtractionMap
]

{ #category : 'shapes' }
MiServiceExtractorBrowser >> shapeForClass: assoc from: extraction [

	| shape methodShapes attributeShapes label domMethods |
	shape := RSComposite new
		         model: assoc key;
		         yourself.
	domMethods := uccg dominatedMethodsFrom:
		              extraction methodsToExtract first.
	methodShapes := ((assoc value select: #isMethod) reject: [ :m |
		                 m name = '<Initializer>' ])
		                collect: [ :m |
			                | lb pds |
			                pds := (uccg predecessors: m) size asString.
			                lb := RSLabel text: m name , '(): ' , pds model: m.
			                (domMethods includes: m) ifTrue: [
				                lb color: (Color fromHexString: '058B71') ].
			                extraction methodsToExtract first = m ifTrue: [
				                lb text: '--->' , lb text.
				                lb color: (Color fromHexString: 'D35400') ].
			                lb ]
		                as: RSGroup.

	attributeShapes := (assoc value select: #isAttribute)
		                   collect: [ :m | RSLabel text: m name model: m ]
		                   as: RSGroup.
	RSVerticalLineLayout on: methodShapes.
	RSVerticalLineLayout on: attributeShapes.

	label := RSComposite new
		         add: (RSLabel text:
					          assoc key name , String space
					          , methodShapes size asString , '/'
					          , assoc key methods size asString);
		         yourself.
	label color: Color red translucent.
	label adjustToChildren.

	label
		when: RSMouseClick
		do: [ :e | MiInspectorBrowser inspect: assoc key ]
		for: self.

	shape add: label.
	shape add: (attributeShapes asShape padding: 10).
	shape add: (methodShapes asShape padding: 10).

	RSVerticalLineLayout new
		alignCenter;
		on: shape children.
	shape adjustToChildren.
	label width: shape width.
	shape border: (RSBorder new
			 width: 1;
			 color: Color black;
			 yourself).
	shape color: Color gray translucent translucent.
	^ shape
]

{ #category : 'actions' }
MiServiceExtractorBrowser >> shapeForExtraction: extraction [

	| shape classShapes label |
	shape := RSComposite new.
	classShapes := extraction classes associations
		               collect: [ :assoc |
		               self shapeForClass: assoc from: extraction ]
		               as: RSGroup.
	RSFlowLayout on: classShapes.
	label := RSComposite new
		         add: (RSLabel text:
					          'Extraction: ' , extraction methodsToExtract first name
					          , '()');
		         yourself.
	label color: (Color fromHexString: '68D094').
	label adjustToChildren.

	label
		when: RSMouseClick
		do: [ :e | MiInspectorBrowser inspect: extraction ]
		for: self.

	shape add: label.
	shape add: (classShapes asShape padding: 10).
	RSVerticalLineLayout new
		alignCenter;
		on: shape children.
	shape adjustToChildren.
	label width: shape width.
	shape border: (RSBorder new
			 width: 1;
			 color: Color black;
			 yourself).
	RSLineBuilder arrowedLine
		withBorderAttachPoint;
		width: 1;
		canvas: canvas canvas;
		shapes:
			((classShapes flatCollect: #allChildren) select: [ :s | s model notNil ]);
		connectToAll: [ :m |
			specModel uccg callGraph at: m ifAbsent: [ {  } ] ].

	^ shape
]
