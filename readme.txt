AnalyzeNNLS    2009.06.03   
Thorarin Bjarnason 
Diagnostic Imaging Services, Interior Health, Kelowna, Canada
Radiology, University of British Columbia, Vancouver, Canada
Last edited 2012.01.27

AnalyzeNNLS is a MatLab ROI-based analysis suite for multiecho MRI data. AnalyzeNNLS creates a T2 distribution from the averaged decay data. Regional fractions and geometric T2 times can be determined. If you use this software, please refernce: Bjarnason TA, Mitchell JR. AnalyzeNNLS: Magnetic resonance multiexponential decay image analysis. Journal of Magnetic Resonance, 206(2); 200-4 (2010).

AnalyzeNNLS will run on any platform runing Matlab and appropirate toolboxes <see Requirements below>.



Documentation

A video podcast has been created that shows how to use AnalyzeNNLS
http://sourceforge.net/docman/display_doc.php?docid=136815&group_id=224181
There is one major change since this documentaitn was created. Users used to specify chi2_min and chi2_max values in the fitting options. Users no longer have to do this.
2009.02.10 - Thorarin Bjarnason




Requirements

	- Any OS running Matlab 2007 b or newer. This software might run on older versions - it is untested. 
	- Requires Image Processing Toolbox. 
	- Requires Statistics Toolbox <for caseread and casewrite>.
	- Might require other toolboxes I am missing
	- Matlab 2007b has ROI issues <possibly all OSs> that should be fixed in >2008 versions of Matlab. The workaround can be determined using: http://www.mathworks.com/support/bugreports/details.html?rp=398256 for Bug 398256 <registration required or contact thorarin bjarnason>
	- Matlab 2007b has performance issues on Mac OSX. The fix is at http://www.mathworks.com/support/bugreports/details.html?rp=412219 for Bug 412219 <registration required or contact thorarin bjarnason>




Credit

AnalyzeNNLS is free to use, however we would appreciate credit for our work. In your publications please cite <as a reference or footnote>: Bjarnason TA, Mitchell JR. AnalyzeNNLS: Magnetic resonance multiexponential decay image analysis. Journal of Magnetic Resonance, 206(2); 200-4 (2010).

Also, we would appreciate a short email to:  coolth at users.sourceforge.net briefly detailing your usage.  If you provide a link to your project in the email (open source or commercial), then we will acknowledge it at sourceforge.

Release notes
Ver 2.4.0
- A flag in UserVar.txt can be set so that AnalyzeNNLS can be used to analyse the real portion of complext multiecho data.
Ver 2.3.0 
- single slice dicom files can be opened directly, instead of requiring conversion to MEID. DICOM functionality assumes one set of single slice data in the directly, consecutively named for echo time, and with .dcm extension. User can select any dcm file and all files will be combined into one dataset.
- UserVar.txt now allows users to use correction factors to compensate for insufficiently suppressed stimulated echos, as per Vermathen P et al, MRM 58: 1145-1156 (2007). This change was made by Petra J.W. Pouwels PhD. Setting these correction factors to 1 does nothing to the data.
- date format has changed from day-Month-year <20-July-2010> to YearMonthDay <20100720>.
- The n-way toolbox <fastnnls.m> is now used instead of lsqnonneg or blocknnls.
 The N-way Toolbox for MATLAB ver. 3.00, http://www.models.life.ku.dk/
 R. Bro & C. A. Andersson
 Faculty of Life Sciences
 Copenhagen University
 DK-1958 Frederiksberg
 Denmark
Ver 2.2.0
- The width of the peaks are now determined by using the full width at maximum height (FWMH). By assuming the peak of interest is normal on a logarithmic scale, the FWMH can be found and the corresponding T2 times, T2long and T2short can be found. A width measure, called geometric mean T2 width ratio (gmT2WR) can be determined as gmT_2WR = T2long/T2short . If the peak of interest is not log-normal gmT2WR is not well defined.
Ver 2.1.0
- Generalized Cross Validation approach to regularization being used
Ver 2.0.2
- Can open Varian .fdf format <mems and sems>



