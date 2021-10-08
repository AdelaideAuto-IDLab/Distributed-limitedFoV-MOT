### Distributed Multi-Object Tracking Under Limited Field of View Sensors

This repository is provided as part of the our TSP paper:

H. V. Nguyen,  H.  Rezatofighi, B.-N. Vo, D. Ranasinghe, "Distributed Multi-Object Tracking Under Limited Field of View Sensors". *IEEE Transactions on Signal Processing*, vol. 69, pp. 5329-5344, 2021, doi: 10.1109/TSP.2021.3103125. [Paper](https://arxiv.org/abs/2012.12990).

If you use our provided codes, please consider cite our paper using:

```
@article{nguyen2021distributed,
	title={Distributed Multi-Object Tracking Under Limited Field of View Sensors},
	author={Nguyen, Hoa Van and Rezatofighi, Hamid and Vo, Ba-Ngu and Ranasinghe, Damith C},
	journal = {{IEEE Transactions on Signal Processing}},
	year={2021
	volume={69},
	number={},
	pages={5329-5344},
	doi={10.1109/TSP.2021.3103125}
}
```



### Brief information

1. All objects move follow a 4D Constant Velocity (x/y position and velocity) with 2D observations (position only).

2. Each node runs an LMB filter with joint prediction and update step, with a measurement-based Adaptive Birth Procedure (from data of previous measurements).

3. Call `demo.m`to run it, with the following settings for different scenarios in the [Paper](https://arxiv.org/abs/2012.12990):

   - `Scenario 1` by a pair of (property, value) of `'case_id',1` in `gen_settings`:  

     ```matlab
     settings =  gen_settings('case_id',1,'sel_pd',0.98);  
     ```

   - `Scenario 2` by a pair of (property, value) of `'case_id',2` in `gen_settings`:  

     ```matlb
     settings =  gen_settings('case_id',2,'sel_pd',0.98);  
     ```

   - `Scenario 3` by a pair of (property, value) of `'case_id',3` in `gen_settings`:  

     ```matlb
     settings =  gen_settings('case_id',3,'sel_pd',0.98);  
     ```

4. We only publish our proposed Track Consensus method:

   - Track consensus using OSPA2`TC-OSPA2` by setting a pair of (property, value) to `'metric_type','ospa_union'` in `gen_model`:

     ```matlab
     model = gen_model(settings,'meas_sigma',10,'lambda_c',10,'track_threshold',0.001,'metric_type','ospa_union'); 
     ```

   - Track consensus using Wasserstein `TC-WASS` by setting a pair of (property, value) to `'metric_type','wasserstein'`:

     ```matlab
     model = gen_model(settings,'meas_sigma',10,'lambda_c',10,'track_threshold',0.001,'metric_type','wasserstein');  
     ```

5. Codes are provided for academic research purposes only. For a commercial license, please contact me at hoavan.nguyen@adelaide.edu.au.

