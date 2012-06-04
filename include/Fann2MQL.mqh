/* Fann2MQL.mq4
 *
 * Copyright (C) 2008-2010 Mariusz Woloszyn
 *
 *  This file is part of Fann2MQL package
 *
 *  Fann2MQL is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  Fann2MQL is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Fann2MQL; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#property copyright "Mariusz Woloszyn"
#property link      ""

#import "Fann2MQL.dll"
int f2M_create_standard(int num_layers, int l1num, int l2num, int l3num, int l4num);
int f2M_create_from_file(string path);
int f2M_run(int ann, double& input_vector[]);
int f2M_destroy(int ann);
int f2M_destroy_all_anns();

double f2M_get_output(int ann, int output);
int  f2M_get_num_input(int ann);
int  f2M_get_num_output(int ann);

int f2M_train(int ann, double& input_vector[], double& output_vector[]);
int f2M_train_fast(int ann, double& input_vector[], double& output_vector[]);
int f2M_randomize_weights(int ann, double min_weight, double max_weight);
double f2M_get_MSE(int ann);
int f2M_save(int ann, string path);
int f2M_reset_MSE(int ann);
int f2M_test(int ann, double& input_vector[], double& output_vector[]);
int f2M_set_act_function_layer(int ann, int activation_function, int layer);
int f2M_set_act_function_hidden(int ann, int activation_function);
int f2M_set_act_function_output(int ann, int activation_function);

/* Threads functions */
int f2M_threads_init(int num_threads);
int f2M_threads_deinit();
int f2M_parallel_init();
int f2M_parallel_deinit();
int f2M_run_threaded(int anns_count, int& anns[], double& input_vector[]);
int f2M_run_parallel(int anns_count, int& anns[], double& input_vector[]);

/* legacy functions */
int f2M_Init(string path);
int f2M_Run(int ann, double& input_vector[]);
int f2M_Destroy(int ann);
int f2M_fann_create_standard(int num_layers, int l1num, int l2num, int l3num, int l4num);
#import

#define F2M_MAX_THREADS	64

#define FANN_DOUBLE_ERROR	-1000000000

#define FANN_LINEAR                     0
#define FANN_THRESHOLD	                1
#define FANN_THRESHOLD_SYMMETRIC        2
#define FANN_SIGMOID                    3
#define FANN_SIGMOID_STEPWISE           4
#define FANN_SIGMOID_SYMMETRIC          5
#define FANN_SIGMOID_SYMMETRIC_STEPWISE 6
#define FANN_GAUSSIAN                   7
#define FANN_GAUSSIAN_SYMMETRIC         8
#define FANN_GAUSSIAN_STEPWISE          9
#define FANN_ELLIOT                     10
#define FANN_ELLIOT_SYMMETRIC           11
#define FANN_LINEAR_PIECE               12
#define FANN_LINEAR_PIECE_SYMMETRIC     13
#define FANN_SIN_SYMMETRIC              14
#define FANN_COS_SYMMETRIC              15
#define FANN_SIN                        16
#define FANN_COS                        17

