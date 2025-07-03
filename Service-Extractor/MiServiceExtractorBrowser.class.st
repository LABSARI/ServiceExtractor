Class {
	#name : 'MiServiceExtractorBrowser',
	#superclass : 'MiAbstractBrowser',
	#instVars : [
		'methodList',
		'functionalityMethods',
		'canvas',
		'submitButton',
		'extractions'
	],
	#category : 'Service-Extractor-Browser',
	#package : 'Service-Extractor',
	#tag : 'Browser'
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

	| methodsToExtract extraction builder |
	
	methodsToExtract := methodList selectedItems.
	methodList selectItems: {  }.
	methodList items: methodList items \ methodsToExtract.
	extraction := ServiceExtractor new
		              extractMethods: methodsToExtract;
		              yourself.
	self model addExtraction: extraction.
	
	
	builder := MiServiceExtractorBuilder new
		           mapModel: self model;
		           container: canvas canvas;
		           build;
		           yourself
	
	"extractionShapes := extractions
		                    collect: [ :e | self shapeForExtraction: e ]
		                    as: RSGroup.
	(RSHorizontalLineLayout withGap: 40) on: extractionShapes.
	
	lb := RSLabel text:
		      'Number of duplicated methods: ' .
	canvas canvas add: lb.
	canvas canvas addAll: extractionShapes.
	dup := (canvas canvas allChildren
		        select: [ :s |
		        s model isMooseObject and: [ s model isMethod ] ]
		        thenCollect: #model) groupedBy: [ :a | a ].
	
	RSVerticalLineLayout new alignLeft on: {
			lb.
			extractionShapes }.
	(canvas canvas allChildren select: [ :s |
		 s model isMooseObject and: [ s model isMethod ] ]) do: [ :s |
		(dup at: s model) size > 1  ifTrue: [
			s color: Color red ] ].
	canvas canvas lines do: #update.
	canvas canvas signalUpdate.
	canvas canvas zoomToFit"
]

{ #category : 'testing' }
MiServiceExtractorBrowser >> canFollowEntity: anObject [

	^ (anObject asMooseGroup allSatisfy: [ :m | m isMethod ]) or: [
		  anObject asMooseGroup allSatisfy: [ :m | m isClass ] ]
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
	list := anEntity anyOne isClass
		        ifTrue: [
		        (anEntity flatCollect: #methods) asOrderedCollection ]
		        ifFalse: [ anEntity asOrderedCollection ].
	list sort: [ :a :b | a parentType name < b parentType name ].
	methodList items: list.
	specModel methodList: list.
	specModel buildCallGraph
]

{ #category : 'initialization' }
MiServiceExtractorBrowser >> initialize [

	super initialize.
	extractions := OrderedCollection new
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

	methodList items ifEmpty: [ ^ self ].
	methodList selectedItems ifEmpty: [ ^ self ].
	self resetCanvas.
	self buildExtractionMap
]

{ #category : 'shapes' }
MiServiceExtractorBrowser >> shapeForClass: assoc from: extraction [

	| shape methodShapes attributeShapes label domMethods |
	shape := RSComposite new
		         model: assoc key;
		         yourself.
	domMethods := extraction methodsToExtract flatCollectAsSet: [ :m |
		              uccg dominatedMethodsFrom: m ].
	methodShapes := ((assoc value select: #isMethod) reject: [ :m |
		                 m name = '<Initializer>' ])
		                collect: [ :m |
			                | lb pds |
			                pds := (uccg predecessors: m) size asString.
			                lb := RSLabel text: m name , '(): ' , pds model: m.
			                (domMethods includes: m) ifTrue: [
				                lb color: (Color fromHexString: '058B71') ].
			                (extraction methodsToExtract includes: m) ifTrue: [
				                lb text: '--->' , lb text.
				                lb color: (Color fromHexString: 'D35400') ].
			                lb
				                when: RSMouseClick
				                do: [ :e |
				                MiInspectorBrowser inspect: (uccg entryPointsUsing: e shape model) ]
				                for: self.
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

	| shape classShapes label methodsName presenterShapes serviceShapes daoShapes otherShapes layers os maxWidth |
	shape := RSComposite new.
	classShapes := extraction classes associations
		               collect: [ :assoc |
		               self shapeForClass: assoc from: extraction ]
		               as: RSGroup.



	presenterShapes := classShapes select: [ :s |
		                   | c |
		                   c := s model.
		                   (c name beginsWith: 'Uc' caseSensitive: false)
			                   and: [
				                   (c name endsWith: 'Impl' caseSensitive: false)
					                   and: [
					                   (c name
						                    includesSubstring: 'usine'
						                    caseSensitive: false) not ] ] ].
	RSFlowLayout on: presenterShapes.
	serviceShapes := classShapes select: [ :s |
		                 | c |
		                 c := s model.
		                 c superclassHierarchy anySatisfy: [ :sc |
			                 sc name = 'ServiceAbstract' ] ].
	RSFlowLayout on: serviceShapes.
	daoShapes := classShapes select: [ :s |
		             | c |
		             c := s model.
		             c superclassHierarchy anySatisfy: [ :sc |
			             sc name = 'DaoEntiteAbstract' ] ].
	RSFlowLayout on: daoShapes.
	otherShapes := classShapes
	               \ (presenterShapes , serviceShapes , daoShapes).
	RSFlowLayout on: otherShapes.


	methodsName := extraction methodsToExtract collect: [ :m |
		               RSLabel text: m parentType name , '>>' , m name ].
	RSVerticalLineLayout new
		alignCenter;
		on: methodsName.

	layers := (RSGroup withAll: {
			           (presenterShapes asShape
				            border: (RSBorder new
						             width: 1;
						             dashArray: #( 5 10 );
						             color: Color black;
						             yourself);
				            padding: 10).
			           (serviceShapes asShape
				            border: (RSBorder new
						             width: 1;
						             dashArray: #( 5 10 );
						             color: Color black;
						             yourself);
				            padding: 10).
			           (daoShapes asShape
				            border: (RSBorder new
						             width: 1;
						             dashArray: #( 5 10 );
						             color: Color black;
						             yourself);
				            padding: 10) }) asShape.
	maxWidth := layers children max: [ :l | l width ].
	layers children do: [ :c | c width: maxWidth ].
	RSVerticalLineLayout new
		gapSize: 20;
		on: layers children.
	layers adjustToChildren.
	os := otherShapes asShape.
	os
		border: (RSBorder new
				 width: 1;
				 dashArray: #( 5 10 );
				 color: Color black;
				 yourself);
		padding: 10.
	RSHorizontalLineLayout new
		alignMiddle;
		gapSize: 20;
		on: {
				os.
				layers }.
	(RSGroup withAll: {
			 os.
			 layers }) asShape padding: 10.
	label := RSComposite new
		         addAll: methodsName;
		         yourself.
	label color: (Color fromHexString: '68D094').
	label adjustToChildren.

	label
		when: RSMouseClick
		do: [ :e | MiInspectorBrowser inspect: extraction ]
		for: self.

	shape add: label.
	shape add: ((RSGroup withAll: {
				  os.
				  layers }) asShape padding: 10).
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
		shapes: ((classShapes flatCollect: #allChildren) select: [ :s |
					 s model notNil ]);
		connectToAll: [ :m |
			specModel uccg callGraph at: m ifAbsent: [ {  } ] ].

	^ shape
]
